import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

private func isObservationIgnored(_ node: AttributeSyntax) -> Bool {
    guard let arguments = node.arguments?.as(LabeledExprListSyntax.self) else {
        return false
    }
    return arguments.contains { argument in
        if let memberAccess = argument.expression.as(MemberAccessExprSyntax.self) {
            return memberAccess.declName.baseName.text == "observationIgnored"
        }
        return argument.expression.trimmedDescription == ".observationIgnored"
    }
}

public struct ValueEntryMacro: AccessorMacro & PeerMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              varDecl.bindingSpecifier.text == "var",
              let binding = varDecl.bindings.first,
              let ident = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
              binding.initializer?.value != nil
        else {
            fatalError()
        }
        
        let name = ident.trimmedDescription
        let ignored = isObservationIgnored(node)
        
        if ignored {
            return [
                """
                    get {
                        self.environmentValue(\\.\(raw: name)) ?? Self.__Value_\(raw: name).defaultValue
                    }
                    set {
                        self.setEnvironment(\\.\(raw: name), to: newValue)
                    }
                """
            ]
        }
        
        return [
            """
                get {
                    self[env: \\.\(raw: name)] ?? Self.__Value_\(raw: name).defaultValue
                }
                set {
                    self[env: \\.\(raw: name)] = newValue
                }
            """
        ]
    }

    
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              varDecl.bindingSpecifier.text == "var",
              let binding = varDecl.bindings.first,
              let ident = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
              binding.initializer?.value != nil
        else {
            return []
        }
        
        let name       = ident.trimmedDescription
        let defaultVal = binding.initializer!.value.trimmedDescription
        
        if let typeName = binding.typeAnnotation?.type.trimmedDescription {
            return [DeclSyntax(
                stringLiteral:
                    """
                    struct __Value_\(name) {
                        public typealias Value = \(typeName)
                        public static var defaultValue: Value { \(defaultVal) }
                    }
                    """
            )]
        } else {
            return [DeclSyntax(
                stringLiteral:
                    """
                    struct __Value_\(name): SwiftUI.EnvironmentKey {
                        @SwiftUICore.__EntryDefaultValue
                        public static var defaultValue = \(defaultVal)
                    }
                    """
            )]
        }
    }
}

@main
struct NavigationValuesMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ValueEntryMacro.self
    ]
}

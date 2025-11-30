import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
public struct StringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }

        return "(\(argument), \(literal: argument.description))"
    }
}


public struct ValueEntryMacro: AccessorMacro {
    public static func expansion(
      of node: AttributeSyntax,
      providingAccessorsOf declaration: some DeclSyntaxProtocol,
      in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        return [
            """
                get {
                    self[env: \(node.arguments)]
                }
                set {
                    self[env: \(node.arguments)] = newValue
                }
            """
        ]   
    }
}


@main
struct NavigationValuesMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        ValueEntryMacro.self,
    ]
}

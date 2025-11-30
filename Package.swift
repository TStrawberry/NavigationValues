// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "NavigationValues",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "NavigationValues",
            targets: [
                "NavigationValues"
            ]
        ),
        .library(
            name: "NavigationValuesMacro",
            targets: ["NavigationValuesMacro"]
        ),
        .executable(
            name: "NavigationValuesMacroClient",
            targets: ["NavigationValuesMacroClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", .upToNextMajor(from: "602.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "NavigationValues",
            dependencies: [
                "NavigationValuesMacro"
            ]
        ),
        .testTarget(
            name: "NavigationValuesTests",
            dependencies: ["NavigationValues"]
        ),
        
        
        .macro(
            name: "NavigationValuesMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(name: "NavigationValuesMacro", dependencies: ["NavigationValuesMacros"]),
        
        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(
            name: "NavigationValuesMacroClient",
            dependencies: ["NavigationValuesMacro"]
        ),
        
        // A test target used to develop the macro implementation.
        .testTarget(
            name: "NavigationValuesMacroTests",
            dependencies: [
                "NavigationValuesMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

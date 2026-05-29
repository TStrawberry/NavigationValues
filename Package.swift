// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "NavigationValues",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(
            name: "NavigationValues",
            targets: [
                "NavigationValues"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", .upToNextMajor(from: "602.0.0")),
    ],
    targets: [
        .target(
            name: "NavigationValues",
            dependencies: [
                "NavigationValuesMacros"
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
        )
    ],
    swiftLanguageModes: [.v6]
)

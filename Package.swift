// swift-tools-version: 6.3

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "GuidelinesDiagnostics",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "GuidelinesDiagnostics",
            targets: ["GuidelinesDiagnostics"]
        ),
        .executable(
            name: "guidelines-diagnostics-concept",
            targets: ["GuidelinesDiagnosticsConcept"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/leviouwendijk/Guidelines.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            from: "603.0.0"
        ),
    ],
    targets: [
        .macro(
            name: "GuidelinesDiagnosticsMacros",
            dependencies: [
                .product(
                    name: "SwiftSyntax",
                    package: "swift-syntax"
                ),
                .product(
                    name: "SwiftSyntaxMacros",
                    package: "swift-syntax"
                ),
                .product(
                    name: "SwiftCompilerPlugin",
                    package: "swift-syntax"
                ),
                .product(
                    name: "SwiftDiagnostics",
                    package: "swift-syntax"
                ),
            ]
        ),

        .target(
            name: "GuidelinesDiagnostics",
            dependencies: [
                .product(
                    name: "Guidelines",
                    package: "Guidelines"
                ),
                "GuidelinesDiagnosticsMacros",
            ]
        ),

        .executableTarget(
            name: "GuidelinesDiagnosticsConcept",
            dependencies: [
                "GuidelinesDiagnostics",
                .product(
                    name: "Guidelines",
                    package: "Guidelines"
                ),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

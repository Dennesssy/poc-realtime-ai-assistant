// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AIAssistantConfig",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "AIAssistantConfig", targets: ["AIAssistantConfig"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "AIAssistantConfig",
            dependencies: [],
            path: ".",
            resources: [
                .process("Resources")
            ]
        )
    ]
)

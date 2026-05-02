// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "GymNutshellCore",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .watchOS(.v11),
        .macOS(.v14),
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "GymNutshellCore",
            targets: ["GymNutshellCore"]
        ),
    ],
    targets: [
        .target(
            name: "GymNutshellCore",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "GymNutshellCoreTests",
            dependencies: ["GymNutshellCore"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

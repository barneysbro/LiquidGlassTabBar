// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LiquidGlassTabBar",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "LiquidGlassTabBar",
            targets: ["LiquidGlassTabBar"]
        )
    ],
    targets: [
        .target(name: "LiquidGlassTabBar", path: "Sources/LiquidGlassTabBar")
    ]
)

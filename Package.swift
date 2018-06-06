// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "overwatch-league",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.0-rc.2.5"),
        .package(url: "https://github.com/BrettRToomey/Jobs.git", from: "1.1.2")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentMySQL", "Vapor", "Jobs"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)


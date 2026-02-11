// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "PartMount",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "PartMount"),
    ]
)

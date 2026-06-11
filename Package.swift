// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "EveryAI",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "EveryAI", targets: ["EveryAI"])
    ],
    targets: [
        .binaryTarget(
            name: "EveryAI",
            path: "EveryAI.xcframework"
        )
    ]
)

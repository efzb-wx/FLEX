// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "NBFLEXReflex",
    platforms: [.iOS(.v13)],
    products: [.library(name: "NBFLEXReflex", type: .dynamic, targets: ["Reflex"])],
    dependencies: [
        .package(url: "https://github.com/NSExceptional/Echo.git", revision: "e912ad88d3524725127f5163a2c5015573078b08")
    ],
    targets: [
        .systemLibrary(name: "FLEX", path: "Support/FLEX"),
        .target(name: "Reflex", dependencies: [.product(name: "Echo", package: "Echo"), "FLEX"], path: "Sources/Reflex")
    ],
    swiftLanguageVersions: [.v5]
)

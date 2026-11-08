// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "NBFLEXReflex",
    platforms: [.iOS(.v13)],
    products: [.library(name: "NBFLEXReflex", type: .dynamic, targets: ["Reflex"])],
    dependencies: [
        .package(url: "https://github.com/NSExceptional/Echo.git", revision: "13c06ca2d2239cf3df7854b4fa6be608a4cd59e5")
    ],
    targets: [
        .systemLibrary(name: "FLEX", path: "Support/FLEX"),
        .target(name: "Reflex", dependencies: [.product(name: "Echo", package: "Echo"), "FLEX"], path: "Sources/Reflex")
    ],
    swiftLanguageVersions: [.v5]
)

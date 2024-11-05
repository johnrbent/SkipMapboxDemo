// swift-tools-version: 5.9
// This is a Skip (https://skip.tools) package,
// containing a Swift Package Manager project
// that will use the Skip build plugin to transpile the
// Swift Package, Sources, and Tests into an
// Android Gradle Project with Kotlin sources and JUnit tests.
import PackageDescription

let package = Package(
    name: "skip-mapbox-demo",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v13), .tvOS(.v16), .watchOS(.v9), .macCatalyst(.v16)],
    products: [
        .library(name: "SkipMapboxDemoApp", type: .dynamic, targets: ["SkipMapboxDemo"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "1.0.8"),
        .package(url: "https://source.skip.tools/skip-ui.git", from: "1.0.0"),
        .package(url: "https://github.com/johnrbent/skip-mapbox.git", branch: "main")
    ],
    targets: [
        .target(
            name: "SkipMapboxDemo",
            dependencies: [
                .product(name: "SkipUI", package: "skip-ui"),
                .product(name: "SkipMapbox", package: "skip-mapbox")
            ],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "skipstone", package: "skip")]
        ),
        .testTarget(name: "SkipMapboxDemoTests", dependencies: ["SkipMapboxDemo", .product(name: "SkipTest", package: "skip")], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)

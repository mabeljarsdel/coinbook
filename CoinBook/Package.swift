// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoinBook",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(name: "CoinBook", targets: ["CoinBook"]),
    ],
    dependencies: [
        .package(name: "Starscream", url: "https://github.com/daltoniam/Starscream", from: "3.1.1"),
        .package(name: "JJLISO8601DateFormatter", url: "https://github.com/michaeleisel/JJLISO8601DateFormatter", from: "0.1.2"),
        .package(name: "ZippyJSON", url: "https://github.com/michaeleisel/ZippyJSON", from: "1.2.4"),
    ],
    targets: [
        .target(name: "CoinBook", dependencies: ["Starscream", "JJLISO8601DateFormatter","ZippyJSON"]),
        .testTarget(name: "CoinBookUnitTests", dependencies: ["CoinBook"]),
        /// Collection of unit tests that can may fail unexpectedly.
        /// These tests depends on external I/O, therefore cannot be tested deterministic.
        /// We need a sort of virtualization or pseudo server and I don't have time for that now.
        .testTarget(name: "CoinBookFlakyUnitTests", dependencies: ["CoinBook"]),
    ]
)

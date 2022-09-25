// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Bells",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Bells",
            targets: ["Bells"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/attaswift/BigInt", from: "5.3.0"),
        
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections", branch: "feature/BitSet"),
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.2"),
        
        // Dev dependencies for tests
        .package(url: "https://github.com/sajjon/BytePattern", from: "0.0.6"),
        .package(url: "https://github.com/typelift/SwiftCheck", from: "0.12.0"),
        .package(url: "https://github.com/llvm-swift/FileCheck", from: "0.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Bells",
            dependencies: [
                "BigInt",
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "RealModule", package: "swift-numerics"),
            ]
        ),
        .testTarget(
            name: "BellsTests",
            dependencies: [
                "Bells",
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "XCTAssertBytesEqual", package: "BytePattern"),
                .product(name: "BytesMutation", package: "BytePattern"),
                "SwiftCheck",
                "FileCheck",
            ]
        ),
    ]
)

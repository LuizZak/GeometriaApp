// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "GeometriaApp",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(
            name: "GeometriaApp",
            targets: ["GeometriaApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/LuizZak/Geometria.git", branch: "main"),
        .package(url: "https://github.com/LuizZak/ImagineUI.git", branch: "master"),
        .package(url: "https://github.com/LuizZak/swift-blend2d.git", branch: "master")
    ],
    targets: [
        .executableTarget(
            name: "GeometriaApp",
            dependencies: [
                "GeometriaAppLib"
            ]),
        .target(
            name: "GeometriaAppLib",
            dependencies: [
                "Geometria",
                "ImagineUI",
                .product(name: "SwiftBlend2D", package: "swift-blend2d")
            ],
            resources: [
                .copy("Resources/NotoSans-Regular.ttf")
            ]),
        .testTarget(
            name: "GeometriaAppTests",
            dependencies: ["GeometriaApp"]),
    ]
)

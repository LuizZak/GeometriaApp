// swift-tools-version:5.4
import PackageDescription

var packageDependencies: [Package.Dependency] =  [
    // TODO: When Swift properly supports -Xswiftc -cross-module-optimization, re-enable external Geometria import.
    // TODO: For now, code is embedded directly into this repository.
    // .package(url: "https://github.com/LuizZak/Geometria.git", branch: "main"),
    .package(url: "https://github.com/apple/swift-numerics.git", from: "1.0.0"),
    .package(url: "https://github.com/LuizZak/ImagineUI.git", .branch("master")),    //.package(url: "https://github.com/LuizZak/ImagineUI.git", branch: "master"),
    .package(name: "SwiftBlend2D", url: "https://github.com/LuizZak/swift-blend2d.git", .branch("master")), //.package(url: "https://github.com/LuizZak/swift-blend2d.git", branch: "master")
    .package(url: "https://github.com/apple/swift-log.git", .branch("main")),
]

var geometriaAppTarget: Target = .executableTarget(
    name: "GeometriaApp"
)

var geometriaAppLibTarget: Target = .target(
name: "GeometriaAppLib",
dependencies: [
    // "Geometria",
    .product(name: "Numerics", package: "swift-numerics"),
    "ImagineUI",
    "SwiftBlend2D",
],
resources: [
    .copy("Resources/NotoSans-Regular.ttf")
])

var osTargets: [Target] = []

#if os(Windows)

packageDependencies.append(contentsOf: [
    .package(name: "SwiftCOM", url: "https://github.com/compnerd/swift-com.git", .revision("ebbc617d3b7ba3a2023988a74bebd118deea4cc5"))
])

geometriaAppTarget.dependencies.append(
    "GeometriaWindows"
)

osTargets.append(
    .target(
        name: "GeometriaWindows",
        dependencies: [
            "ImagineUI",
            "SwiftBlend2D",
            "GeometriaAppLib",
            "SwiftCOM",
            .product(name: "Logging", package: "swift-log"),
        ],
        exclude: [
            "GeometriaApp.exe.manifest"
        ])
)

#elseif os(macOS)

geometriaAppTarget.dependencies.append(
    "GeometriaMacOS"
)
osTargets.append(
    .target(
        name: "GeometriaMacOS",
        dependencies: [
            "ImagineUI",
            "SwiftBlend2D",
            "GeometriaAppLib"
        ])
)

#endif

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
    dependencies: packageDependencies,
    targets: [
        geometriaAppTarget,
        geometriaAppLibTarget,
        .testTarget(
            name: "GeometriaAppTests",
            dependencies: ["GeometriaApp"]),
    ] + osTargets
)

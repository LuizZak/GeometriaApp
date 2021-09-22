// swift-tools-version:5.4
import PackageDescription

var osTargets: [Target] = []

var geometriaAppTarget: Target = .target(
name: "GeometriaAppLib",
dependencies: [
    // "Geometria",
    "ImagineUI",
    "SwiftBlend2D", //.product(name: "SwiftBlend2D", package: "swift-blend2d")
],
resources: [
    .copy("Resources/NotoSans-Regular.ttf")
])

#if os(Windows)

geometriaAppTarget.dependencies.append(
    .target(name: "GeometriaWindows", condition: .when(platforms: [.windows]))
)

osTargets.append(
    .target(
        name: "GeometriaWindows",
        dependencies: [
            "ImagineUI",
            "SwiftBlend2D"
        ])
)

#elseif os(macOS)

geometriaAppTarget.dependencies.append(
    .target(name: "GeometriaMacOS", condition: .when(platforms: [.macOS]))
)

osTargets.append(
    .target(
        name: "GeometriaMacOS",
        dependencies: [
            "ImagineUI",
            "SwiftBlend2D"
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
    dependencies: [
        // TODO: When Swift properly supports -Xswiftc -cross-module-optimization, re-enable external Geometria import.
        // TODO: For now, code is embedded directly into this repository.
        // .package(url: "https://github.com/LuizZak/Geometria.git", branch: "main"),
        .package(url: "https://github.com/LuizZak/ImagineUI.git", .branch("master")),    //.package(url: "https://github.com/LuizZak/ImagineUI.git", branch: "master"),
        .package(name: "SwiftBlend2D", url: "https://github.com/LuizZak/swift-blend2d.git", .branch("master")) //.package(url: "https://github.com/LuizZak/swift-blend2d.git", branch: "master")
    ],
    targets: [
        .executableTarget(
            name: "GeometriaApp",
            dependencies: [
                "GeometriaAppLib"
            ]),
        geometriaAppTarget,
        .testTarget(
            name: "GeometriaAppTests",
            dependencies: ["GeometriaApp"]),
    ] + osTargets
)

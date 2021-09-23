// swift-tools-version:5.4
import PackageDescription

var packageDependencies: [Package.Dependency] =  [
    // TODO: When Swift properly supports -Xswiftc -cross-module-optimization, re-enable external Geometria import.
    // TODO: For now, code is embedded directly into this repository.
    // .package(url: "https://github.com/LuizZak/Geometria.git", branch: "main"),
    .package(url: "https://github.com/LuizZak/ImagineUI.git", .branch("master")),    //.package(url: "https://github.com/LuizZak/ImagineUI.git", branch: "master"),
    .package(name: "SwiftBlend2D", url: "https://github.com/LuizZak/swift-blend2d.git", .branch("master")), //.package(url: "https://github.com/LuizZak/swift-blend2d.git", branch: "master")
]

var geometriaAppTarget: Target = .executableTarget(
    name: "GeometriaApp"
)

var geometriaAppLibTarget: Target = .target(
name: "GeometriaAppLib",
dependencies: [
    // "Geometria",
    "ImagineUI",
    "SwiftBlend2D", //.product(name: "SwiftBlend2D", package: "swift-blend2d")
],
resources: [
    .copy("Resources/NotoSans-Regular.ttf")
])

var osTargets: [Target] = []

#if os(Windows)

packageDependencies.append(
    .package(name: "SwiftWin32", url: "https://github.com/compnerd/swift-win32", .branch("main"))
)

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
            "SwiftWin32"
        ],
        exclude: [
            "GeometriaApp.exe.manifest",
            "Info.plist"
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

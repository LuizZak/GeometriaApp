// swift-tools-version:5.5
import PackageDescription
import class Foundation.ProcessInfo

let reportingSwiftSettings: [SwiftSetting] = [
    .unsafeFlags([
        "-driver-time-compilation",
        "-Xfrontend",
        "-warn-long-function-bodies=1000",
        "-Xfrontend",
        "-warn-long-expression-type-checking=300"
    ])
]

var packageDependencies: [Package.Dependency] =  [
    .package(url: "https://github.com/apple/swift-numerics.git", from: "1.0.0"),
    .package(url: "https://github.com/LuizZak/ImagineUI.git", .branch("master")),    //.package(url: "https://github.com/LuizZak/ImagineUI.git", branch: "master"),
    .package(name: "SwiftBlend2D", url: "https://github.com/LuizZak/swift-blend2d.git", .branch("master")), //.package(url: "https://github.com/LuizZak/swift-blend2d.git", branch: "master")
]

var targets: [Target] = []

// MARK: - Target definitions

var geometriaAppTarget: Target = .executableTarget(
    name: "GeometriaApp"
)

var geometriaAppLibTarget: Target = .target(
    name: "GeometriaAppLib",
    dependencies: [
        "Geometria",
        .product(name: "Numerics", package: "swift-numerics"),
        "ImagineUI",
        .product(name: "Blend2DRenderer", package: "ImagineUI"),
        "SwiftBlend2D",
    ],
    exclude: [
        "Resources/FiraCode-License.txt"
    ],
    resources: [
        .copy("Resources/FiraCode-Bold.ttf"),
        .copy("Resources/FiraCode-Light.ttf"),
        .copy("Resources/FiraCode-Medium.ttf"),
        .copy("Resources/FiraCode-Regular.ttf"),
        .copy("Resources/FiraCode-Retina.ttf"),
        .copy("Resources/FiraCode-SemiBold.ttf"),
        .copy("Resources/NotoSans-Regular.ttf"),
    ],
    swiftSettings: [
        
    ]
)
if ProcessInfo.processInfo.environment["REPORT_BUILD_TIME"] == "YES" {
    geometriaAppLibTarget.swiftSettings?.append(contentsOf: reportingSwiftSettings)
}

// MARK: - Embedded Geometria target

// TODO: When Swift properly supports -Xswiftc -cross-module-optimization, re-enable external Geometria import by default.
// TODO: For now, code is embedded directly into this repository.
if ProcessInfo.processInfo.environment["USE_GEOMETRIA_DEPENDENCY"] == "YES" {
    packageDependencies.append(
        .package(url: "https://github.com/LuizZak/Geometria.git", branch: "main")
    )
} else {
    targets.append(
        .target(
            name: "Geometria",
            dependencies: [
                .product(name: "Numerics", package: "swift-numerics"),
            ],
            swiftSettings: []
        )
    )
    geometriaAppLibTarget.swiftSettings?.append(
        .define("GEOMETRIA_EMBEDDED")
    )
}

#if os(Windows)

// Append settings required to run the executable on Windows
#if true

geometriaAppTarget.exclude.append("main+macOS.swift")
geometriaAppTarget.swiftSettings = [
    .unsafeFlags([
        "-parse-as-library",
    ])
]
geometriaAppTarget.linkerSettings = [
    .linkedLibrary("User32"),
    .linkedLibrary("ComCtl32"),
    .unsafeFlags([
        "-Xlinker",
        "/DEBUG",
    ], .when(configuration: .debug)),
    .unsafeFlags([
        "-Xlinker",
        "/SUBSYSTEM:WINDOWS",
    ])
]

#endif

packageDependencies.append(
    .package(url: "https://github.com/LuizZak/ImagineUI-Win.git", .branch("main"))
)

targets.append(
    .target(
        name: "GeometriaWindows",
        dependencies: [
            "SwiftBlend2D",
            "ImagineUI-Win",
            .product(name: "Blend2DRenderer", package: "ImagineUI"),
            "GeometriaAppLib"
        ],
        exclude: [
            "GeometriaApp.exe.manifest"
        ])
)

geometriaAppTarget.dependencies.append(
    "GeometriaWindows"
)

#elseif os(macOS)

geometriaAppTarget.exclude.append("main+win.swift")
geometriaAppTarget.dependencies.append(
    "GeometriaMacOS"
)
targets.append(
    .target(
        name: "GeometriaMacOS",
        dependencies: [
            "ImagineUI",
            "SwiftBlend2D",
            "GeometriaAppLib"
        ])
)

#endif

targets.append(geometriaAppTarget)
targets.append(geometriaAppLibTarget)

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
    targets: targets
)

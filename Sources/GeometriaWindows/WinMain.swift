import Foundation
import WinSDK
import SwiftCOM
import MinWin32
import ImagineUI_Win
import GeometriaAppLib

var app: ImagineUIApp!

public func start() throws -> CInt {
    try? setupLogging()

    let delegate = GeometriaAppDelegate()
    let fontPath = Resources.bundle.path(forResource: "NotoSans-Regular", ofType: "ttf")!

    if !FileManager.default.fileExists(atPath: fontPath) {
        WinLogger.error("Failed to find default font face at path \(fontPath)")
        fatalError()
    }

    let settings = ImagineUIAppStartupSettings(defaultFontPath: fontPath)

    app = ImagineUIApp(delegate: delegate)
    return try app.run(settings: settings)
}

func setupLogging() throws {
    let appDataPath = try SystemPaths.localAppData()

    let logFolder =
    appDataPath
        .appendingPathComponent("GeometriaApp")
        .appendingPathComponent("Sample")

    try FileManager.default.createDirectory(at: logFolder, withIntermediateDirectories: true)

    let logPath =
    logFolder
        .appendingPathComponent("log.txt")

    try WinLogger.setup(logFileUrl: logPath, label: "com.GeometriaApp.log")
}

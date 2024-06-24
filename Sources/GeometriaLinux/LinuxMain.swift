import Foundation
import CX11
import MinX11
import ImagineUI_X11
import GeometriaAppLib

var app: ImagineUIApp!

public func startApp() throws -> CInt {
    try? setupLogging()

    let delegate = GeometriaAppDelegate()
    let fontPath = Resources.bundle.path(forResource: "NotoSans-Regular", ofType: "ttf")!

    if !FileManager.default.fileExists(atPath: fontPath) {
        X11Logger.error("Failed to find default font face at path \(fontPath)")
        fatalError()
    }

    let settings = ImagineUIAppStartupSettings(defaultFontPath: fontPath)

    app = ImagineUIApp(delegate: delegate)
    return try app.run(settings: settings)
}

func setupLogging() throws {
    let appDataPath = FileManager.default.temporaryDirectory

    let logFolder =
    appDataPath
        .appendingPathComponent("ImagineUI-Win")
        .appendingPathComponent("Sample")

    try FileManager.default.createDirectory(at: logFolder, withIntermediateDirectories: true)

    let logPath =
    logFolder
        .appendingPathComponent("log.txt")

    try X11Logger.setup(logFileUrl: logPath, label: "com.imagineui-win.sample.log")
}

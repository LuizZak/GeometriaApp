import AppKit
import SwiftUI

// SwiftUI in Swift Package Manager code by:
// https://theswiftdev.com/how-to-build-macos-apps-using-only-the-swift-package-manager/

class AppDelegate: NSObject, NSApplicationDelegate {
    let window = NSWindow()
    let windowDelegate = WindowDelegate()
    
    let title = "Geometria Tests"
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let appMenu = NSMenuItem()
        appMenu.submenu = NSMenu()
        appMenu.submenu?.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        let mainMenu = NSMenu(title: title)
        mainMenu.addItem(appMenu)
        NSApplication.shared.mainMenu = mainMenu
        
        let size = CGSize(width: 400, height: 300)
        window.setContentSize(size)
        window.styleMask = [.closable, .miniaturizable, .resizable, .titled]
        window.delegate = windowDelegate
        window.title = title
        
        let view = NSHostingView(rootView: AppView())
        view.frame = CGRect(origin: .zero, size: size)
        view.autoresizingMask = [.height, .width]
        window.contentView!.addSubview(view)
        window.center()
        window.makeKeyAndOrderFront(window)
        
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}

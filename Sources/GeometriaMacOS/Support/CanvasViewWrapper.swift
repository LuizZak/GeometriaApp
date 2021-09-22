import AppKit
import SwiftUI

struct CanvasViewWrapper: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        return CanvasView(frame: .init(x: 0, y: 0, width: 300, height: 300))
    }
    
    func updateNSView(_ view: NSView, context: Context) {
        view.layer?.backgroundColor = .white
    }
}

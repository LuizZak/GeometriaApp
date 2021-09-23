import Foundation
import SwiftBlend2D
import ImagineUI

public protocol Blend2DAppDelegate: AnyObject {
    func invalidate(bounds: UIRectangle)
    func setMouseCursor(_ cursor: MouseCursorKind)
    func setMouseHiddenUntilMouseMoves()
}

public protocol Blend2DApp: AnyObject {
    var width: Int { get }
    var height: Int { get }
    var appRenderScale: BLPoint { get }
    
    func willStartLiveResize()
    func didEndLiveResize()
    func resize(width: Int, height: Int)
    
    func update(_ time: TimeInterval)
    func performLayout()
    func render(context ctx: BLContext)
    
    func mouseDown(event: MouseEventArgs)
    func mouseMoved(event: MouseEventArgs)
    func mouseUp(event: MouseEventArgs)
    func mouseScroll(event: MouseEventArgs)
    
    func keyDown(event: KeyEventArgs)
    func keyUp(event: KeyEventArgs)
}

public extension Blend2DApp {
    func willStartLiveResize() { }
    func didEndLiveResize() { }
    
    func update(_ time: TimeInterval) {}
    
    func mouseDown(event: MouseEventArgs) { }
    func mouseMoved(event: MouseEventArgs) { }
    func mouseUp(event: MouseEventArgs) { }
    func mouseScroll(event: MouseEventArgs) { }
    
    func keyDown(event: KeyEventArgs) { }
    func keyUp(event: KeyEventArgs) { }
}

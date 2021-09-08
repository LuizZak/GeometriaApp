import Foundation
import SwiftBlend2D
import ImagineUI

protocol Blend2DSampleDelegate: AnyObject {
    func invalidate(bounds: UIRectangle)
}

protocol Blend2DSample: AnyObject {
    var width: Int { get }
    var height: Int { get }
    var sampleRenderScale: BLPoint { get }
    
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

extension Blend2DSample {
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

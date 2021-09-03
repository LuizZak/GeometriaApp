import SwiftBlend2D

struct MouseEventArgs {
    var location: Vector
    var buttons: MouseButton
    var delta: Vector
    var clicks: Int
    
    init(location: Vector,
         buttons: MouseButton,
         delta: Vector,
         clicks: Int) {
        
        self.location = location
        self.buttons = buttons
        self.delta = delta
        self.clicks = clicks
    }
}

struct MouseButton: OptionSet {
    var rawValue: Int
    
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    static let none = MouseButton([])
    static let left = MouseButton(rawValue: 0b1)
    static let right = MouseButton(rawValue: 0b01)
    static let middle = MouseButton(rawValue: 0b001)
}

enum MouseEventType {
    case mouseDown
    case mouseMove
    case mouseUp
    case mouseClick
    case mouseDoubleClick
    case mouseWheel
}

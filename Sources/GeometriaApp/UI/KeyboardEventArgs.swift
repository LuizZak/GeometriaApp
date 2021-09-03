class KeyPressEventArgs {
    let keyChar: Character
    let modifiers: KeyboardModifier
    var handled: Bool
    
    init(keyChar: Character, modifiers: KeyboardModifier) {
        self.keyChar = keyChar
        self.modifiers = modifiers
        self.handled = false
    }
}

class KeyEventArgs {
    let keyCode: Keys
    let keyChar: String?
    let modifiers: KeyboardModifier
    var handled: Bool
    
    init(keyCode: Keys, keyChar: String?, modifiers: KeyboardModifier) {
        self.keyCode = keyCode
        self.keyChar = keyChar
        self.modifiers = modifiers
        self.handled = false
    }
}

struct PreviewKeyDownEventArgs {
    var modifiers: KeyboardModifier
}

enum KeyboardEventType {
    case keyDown
    case keyPress
    case keyUp
    case previewKeyDown
}

struct KeyboardModifier: OptionSet {
    var rawValue: Int
    
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    static let none = KeyboardModifier([])
    static let shift = KeyboardModifier(rawValue: 0b1)
    static let control = KeyboardModifier(rawValue: 0b10)
    static let alt = KeyboardModifier(rawValue: 0b100)
    
#if os(macOS)
    /// Note: Only available on macOS
    static let command = KeyboardModifier(rawValue: 0b1000)
    
    /// Note: Only available on macOS
    static let option = KeyboardModifier(rawValue: 0b10000)
    
    /// Note: Only available on macOS
    static let numericPad = KeyboardModifier(rawValue: 0b100000)
#endif
}

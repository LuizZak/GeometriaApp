import AppKit

class MacOSTextClipboard: TextClipboard {
    func getText() -> String? {
        NSPasteboard.general.string(forType: .string)
    }
    
    func setText(_ text: String) {
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(text, forType: .string)
    }
    
    func containsText() -> Bool {
        return getText() != nil
    }
}

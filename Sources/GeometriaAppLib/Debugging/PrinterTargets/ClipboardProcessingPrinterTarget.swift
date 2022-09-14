import ImagineUI

public class ClipboardProcessingPrinterTarget: ProcessingPrinterTarget {
    var clipboard: TextClipboard

    init(clipboard: TextClipboard) {
        self.clipboard = clipboard
    }

    public func printBuffer(_ buffer: String) {
        clipboard.setText(buffer)
    }
}

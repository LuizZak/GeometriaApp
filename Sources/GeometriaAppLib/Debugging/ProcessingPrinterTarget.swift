/// Protocol for a target that receives the output buffer of a `ProcessingPrinter`
/// object.
public protocol ProcessingPrinterTarget {
    func printBuffer(_ buffer: String)
}

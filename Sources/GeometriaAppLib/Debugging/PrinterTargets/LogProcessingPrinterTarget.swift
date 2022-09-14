public class LogProcessingPrinterTarget: ProcessingPrinterTarget {
    public func printBuffer(_ buffer: String) {
        GeometriaLogger.info(buffer)
    }
}

public enum GeometriaLogger {
    public static var logger: LoggerType?

    public static func info(
        _ message: @autoclosure () -> CustomStringConvertible,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        logger?.info(
            message().description,
            file: file,
            function: function,
            line: line
        )
    }

    public static func warning(
        _ message: @autoclosure () -> CustomStringConvertible,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        logger?.warning(
            message().description,
            file: file,
            function: function,
            line: line
        )
    }

    public static func error(
        _ message: @autoclosure () -> CustomStringConvertible,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        logger?.error(
            message().description,
            file: file,
            function: function,
            line: line
        )
    }

    public static func critical(
        _ message: @autoclosure () -> CustomStringConvertible,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        logger?.critical(
            message().description,
            file: file,
            function: function,
            line: line
        )
    }
}

import MinWin32
import GeometriaAppLib

public class WinLoggerWrapper: LoggerType {
    public func info(
        _ message: @autoclosure () -> String,
        file: String,
        function: String,
        line: UInt
    ) {
        WinLogger.info(
            .init(stringLiteral: message()),
            file: file,
            function: function,
            line: line
        )
    }

    public func warning(
        _ message: @autoclosure () -> String,
        file: String,
        function: String,
        line: UInt
    ) {
        WinLogger.warning(
            .init(stringLiteral: message()),
            file: file,
            function: function,
            line: line
        )
    }

    public func error(
        _ message: @autoclosure () -> String,
        file: String,
        function: String,
        line: UInt
    ) {
        WinLogger.error(
            .init(stringLiteral: message()),
            file: file,
            function: function,
            line: line
        )
    }

    public func critical(
        _ message: @autoclosure () -> String,
        file: String,
        function: String,
        line: UInt
    ) {
        WinLogger.critical(
            .init(stringLiteral: message()),
            file: file,
            function: function,
            line: line
        )
    }
}

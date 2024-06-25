import GeometriaAppLib
import ImagineUI
import Blend2DRenderer

/// Internal interpolated string for standardized display of tooltips and other
/// attributed text strings.
struct FormattedInterpolatedString: ExpressibleByStringInterpolation {
    static var monoFont: Font = {
        // TODO: Make this font loading renderer-agnostic
        let context = Blend2DRendererContext()
        let fontPath = GeometriaAppLib.Resources.bundle.path(forResource: "FiraCode-Bold", ofType: "ttf")!

        let fontFace = try! context.fontManager.loadFontFace(fromPath: fontPath)

        return fontFace.font(withSize: 12)
    }()

    var result: AttributedText

    init(stringLiteral value: String) {
        result = AttributedText(value)
    }

    init(stringInterpolation: StringInterpolation) {
        result = stringInterpolation.output
    }

    struct StringInterpolation: StringInterpolationProtocol {
        var output: AttributedText = ""

        init(literalCapacity: Int, interpolationCount: Int) {
            output.reserveCapacity(segmentCount: interpolationCount)
        }

        mutating func appendLiteral(_ literal: String) {
            output.append(literal)
        }

        mutating func appendInterpolation<T>(_ literal: T, attributes: AttributedText.Attributes) {
            output.append("\(literal)", attributes: attributes)
        }

        mutating func appendInterpolation(image: any Image) {
            output.append(" ", attributes: [.image: ImageAttribute(image: image)])
        }

        mutating func appendInterpolation(dataType literal: SceneNodeDataType) {
            output.append("\(literal)", attributes: [.foregroundColor: Color.fuchsia])
        }

        mutating func appendInterpolation<T>(muted literal: T) {
            output.append("\(literal)", attributes: [.foregroundColor: Color.gray])
        }

        mutating func appendInterpolation<T>(symbol literal: T) {
            output.append("\(literal)", attributes: [.font: FormattedInterpolatedString.monoFont])
        }

        mutating func appendInterpolation<T>(_ literal: T) {
            output.append("\(literal)")
        }
    }
}

/// Provides support for tooltip formatting based on interpolated strings.
func formatTooltip(_ tooltip: FormattedInterpolatedString) -> Tooltip {
    return .init(text: tooltip.result)
}

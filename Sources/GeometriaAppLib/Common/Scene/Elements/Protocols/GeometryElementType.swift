public protocol GeometryElementType: Element {
    associatedtype GeometryType

    var geometry: GeometryType { get }
}

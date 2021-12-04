/// Protocol for fixed-length tuple elements
protocol TupleElementType: Element {
    /// Array of elements in this tuple.
    var elements: [Element] { get }
}

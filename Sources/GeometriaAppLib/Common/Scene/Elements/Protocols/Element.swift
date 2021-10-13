/// Base protocol for scene graph elements
protocol Element {
    mutating func attributeIds(_ idFactory: inout ElementIdFactory)

    /// Returns an item on this raytracing element matching a specified id.
    /// Returns `nil` if no element with the given ID was found on this element
    /// or any of its sub-elements.
    func queryScene(id: Int) -> Element?

    /// Accepts a visit from a given visitor object.
    ///
    /// Should not call `.accept()` automatically for nested elements, leaving
    /// the choice up to the visitor object.
    func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType
}

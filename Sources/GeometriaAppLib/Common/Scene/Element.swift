/// Base protocol for scene graph elements.
public protocol Element {
    /// Type for identifiers of elements
    typealias Id = Int

    /// Gets a unique identifier for this node.
    var id: Element.Id { get set }

    /// Uses the given element identifier factory to generate an ID for this
    /// element, and any further element in its hierarchy, in place.
    mutating func attributeIds(_ idFactory: inout ElementIdFactory)

    /// Uses the given element identifier factory to generate an ID for this
    /// element, and any further element in its hierarchy, returning the resulting
    /// mutated hierarchy.
    func withAttributedIds(_ idFactory: inout ElementIdFactory) -> Self

    /// Returns an item on this scene element matching a specified id.
    /// Returns `nil` if no element with the given ID was found on this element
    /// or any of its sub-elements.
    func queryScene(id: Element.Id) -> Element?

    /// Accepts a visit from a given visitor object.
    ///
    /// Should not call `.accept()` automatically for nested elements, leaving
    /// the choice up to the visitor object.
    func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType
}

extension Element {
    public func withAttributedIds(_ idFactory: inout ElementIdFactory) -> Self {
        var result = self
        result.attributeIds(&idFactory)
        return result
    }
}

/// Base protocol for scene graph elements.
public protocol Element {
    /// Type for identifiers of elements
    typealias Id = Int

    /// Gets a unique identifier for this node.
    var id: Element.Id { get set }

    mutating func attributeIds(_ idFactory: inout ElementIdFactory)

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

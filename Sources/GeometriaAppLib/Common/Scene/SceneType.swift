import SwiftBlend2D

protocol SceneType {
    var skyColor: BLRgba32 { get }
    var sunDirection: RVector3D { get }

    mutating func attributeIds(_ idFactory: inout ElementIdFactory)

    /// Returns an item on this scene matching a specified id, across all elements
    /// on the scene.
    /// Returns `nil` if no element with the given ID was found on this scene.
    func queryScene(id: Int) -> Element?

    /// Returns the material associated with a given material ID.
    func material(id: Int) -> Material?

    /// Gets the full material map for this scene type.
    func materialMap() -> MaterialMap

    /// Walks a visitor through this scene's elements.
    func walk<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType
}

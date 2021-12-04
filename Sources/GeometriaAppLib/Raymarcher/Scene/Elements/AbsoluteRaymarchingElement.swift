/// Returns the absolute of the distance of the underlying geometry
struct AbsoluteRaymarchingElement<T: RaymarchingElement>: RaymarchingElement {
    var id: Int = 0
    var element: T

    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        let result = element.signedDistance(to: point, current: .emptyResult())

        return min(current, abs(result))
    }

    @inlinable
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()

        element.attributeIds(&idFactory)
    }

    @inlinable
    func queryScene(id: Int) -> Element? {
        element.queryScene(id: id)
    }

    func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }

    func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension RaymarchingElement {
    @_transparent
    func absolute() -> AbsoluteRaymarchingElement<Self> {
        .init(element: self)
    }
}

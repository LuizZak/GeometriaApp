/// Returns the absolute of the distance of the underlying geometry
public struct AbsoluteRaymarchingElement<T: RaymarchingElement>: RaymarchingElement {
    public var id: Int = 0
    public var element: T

    public init(id: Int = 0, element: T) {
        self.id = id
        self.element = element
    }

    @inlinable
    public func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        let result = element.signedDistance(to: point, current: .emptyResult())

        return min(current, abs(result))
    }

    @inlinable
    public mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()

        element.attributeIds(&idFactory)
    }

    @inlinable
    public func queryScene(id: Int) -> Element? {
        element.queryScene(id: id)
    }

    public func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }

    public func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension RaymarchingElement {
    @_transparent
    public func absolute() -> AbsoluteRaymarchingElement<Self> {
        .init(element: self)
    }
}

#if canImport(Geometria)
import Geometria
#endif

public struct ModuloRaymarchingElement<T: RaymarchingElement>: RaymarchingElement {
    public var id: Int = 0
    public var element: T
    public var phase: RVector3D

    @_transparent
    public func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        element.signedDistance(to: abs(point) % phase, current: current)
    }
}

extension ModuloRaymarchingElement: Element {
    public mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()

        element.attributeIds(&idFactory)
    }

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

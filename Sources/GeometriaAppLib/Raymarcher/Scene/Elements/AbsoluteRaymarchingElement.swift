/// Returns the absolute of the distance of the underlying geometry
struct AbsoluteRaymarchingElement<T: RaymarchingElement>: RaymarchingElement {
    var element: T

    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        let result = element.signedDistance(to: point, current: .emptyResult())

        return min(current, abs(result))
    }

    @inlinable
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        element.attributeIds(&idFactory)
    }

    @inlinable
    func queryScene(id: Int) -> Element? {
        element.queryScene(id: id)
    }
}

extension RaymarchingElement {
    @_transparent
    func absolute() -> AbsoluteRaymarchingElement<Self> {
        .init(element: self)
    }
}

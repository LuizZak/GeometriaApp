public typealias DiskRaymarchingElement = DiskElement

extension DiskRaymarchingElement: RaymarchingElement {
    @inlinable
    public func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        let distance = geometry.signedDistance(to: point)
        
        guard distance < current.distance else {
            return current
        }

        return .init(distance: distance, material: material)
    }

    public func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

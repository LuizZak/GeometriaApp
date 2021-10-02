import SwiftBlend2D

struct PlaneRaymarchingElement: RaymarchingElement {
    var geometry: RPlane3D
    var material: RaymarcherMaterial

    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        let distance = geometry.signedDistance(to: point)
        
        guard distance < current.distance else {
            return current
        }

        return .init(distance: distance, material: material)
    }
}

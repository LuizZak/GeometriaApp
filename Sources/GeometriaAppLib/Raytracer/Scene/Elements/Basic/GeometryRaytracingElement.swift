struct GeometryRaytracingElement<T: Convex3Type>: RaytracingElement where T.Vector == RVector3D {
    var id: Int = 0
    var geometry: T
    var material: RaytracingMaterial
    
    func raycast(partial: Scene.PartialRayResult) -> Scene.PartialRayResult {
        let intersection = partial.intersect(geometry)
        guard let hit = RayHit(findingPointOfInterestOf: partial.ignoring,
                               intersection: intersection,
                               id: id) else {
            return partial
        }
        
        return partial.withHit(hit)
    }
}

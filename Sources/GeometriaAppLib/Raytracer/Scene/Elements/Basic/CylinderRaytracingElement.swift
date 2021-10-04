struct CylinderRaytracingElement: RaytracingElement {
    var id: Int = 0
    var geometry: RCylinder3D
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

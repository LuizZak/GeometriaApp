struct DiskRaytracingElement: RaytracingElement {
    var id: Int = 0
    var geometry: RDisk3D
    var material: RaytracingMaterial
    
    func raycast(partial: Scene.PartialRayResult) -> Scene.PartialRayResult {
        let intersection = intersection(partial)
        guard let hit = RayHit(findingPointOfInterestOf: partial.ignoring,
                               intersection: intersection,
                               id: id) else {
            return partial
        }
        
        return partial.withHit(hit)
    }
    
    private func intersection(_ partial: Scene.PartialRayResult) -> ConvexLineIntersection<RVector3D> {
        guard let inter = intersectionPoint(partial) else {
            return .noIntersection
        }
        
        let dSquared = inter.distanceSquared(to: partial.ray.start)
        guard dSquared < partial.rayMagnitudeSquared else {
            return .noIntersection
        }
        
        var normal: RVector3D = geometry.normal
        if normal.dot(partial.ray.direction) > 0 {
            normal = -normal
        }
        
        return .singlePoint(PointNormal(point: inter, normal: normal))
    }
    
    private func intersectionPoint(_ partial: Scene.PartialRayResult) -> RVector3D? {
        if partial.rayMagnitudeSquared.isFinite {
            return geometry.intersection(with: partial.lineSegment)
        }
        
        return geometry.intersection(with: partial.ray)
    }
}

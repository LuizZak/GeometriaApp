struct PlaneRaytracingElement: RaytracingElement {
    var id: Int = 0
    var geometry: RPlane3D
    var material: RaytracingMaterial
    
    func raycast(query: RayQuery) -> RayQuery {
        let intersection = intersection(query)
        guard let hit = RayHit(findingPointOfInterestOf: query.ignoring,
                               intersection: intersection,
                               material: material,
                               id: id) else {
            return query
        }
        
        return query.withHit(hit)
    }

    func raycast(query: RayQuery, results: inout [RayHit]) {
        let intersection = intersection(query)
        guard let hit = RayHit(findingPointOfInterestOf: query.ignoring,
                               intersection: intersection,
                               material: material,
                               id: id) else {
            return
        }

        results.append(hit)
    }
    
    private func intersection(_ query: RayQuery) -> ConvexLineIntersection<RVector3D> {
        guard let inter = intersectionPoint(query) else {
            return .noIntersection
        }
        
        let dSquared = inter.distanceSquared(to: query.ray.start)
        guard dSquared < query.rayMagnitudeSquared else {
            return .noIntersection
        }
        
        var normal: RVector3D = geometry.normal
        if normal.dot(query.ray.direction) > 0 {
            normal = -normal
        }
        
        return .singlePoint(PointNormal(point: inter, normal: normal))
    }
    
    private func intersectionPoint(_ query: RayQuery) -> RVector3D? {
        if query.rayMagnitudeSquared.isFinite {
            return geometry.intersection(with: query.lineSegment)
        }
        
        return geometry.intersection(with: query.ray)
    }
    
    mutating func attributeIds(_ idFactory: inout RaytracingElementIdFactory) {
        id = idFactory.makeId()
    }
}

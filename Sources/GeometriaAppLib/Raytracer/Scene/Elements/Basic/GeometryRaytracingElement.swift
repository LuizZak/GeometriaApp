struct GeometryRaytracingElement<T: Convex3Type>: RaytracingElement where T.Vector == RVector3D {
    var id: Int = 0
    var geometry: T
    var material: RaytracingMaterial
    
    func raycast(query: RayQuery) -> RayQuery {
        guard !query.ignoring.shouldIgnoreFully(id: id) else {
            return query
        }

        let intersection = query.intersect(geometry)
        guard let hit = RayHit(findingPointOfInterestOf: query.ignoring,
                               intersection: intersection,
                               material: material,
                               id: id) else {
            return query
        }
        
        return query.withHit(hit)
    }

    func raycast(query: RayQuery, results: inout [RayHit]) {
        guard !query.ignoring.shouldIgnoreFully(id: id) else {
            return
        }

        let intersection = query.intersect(geometry)
        guard let hit = RayHit(findingPointOfInterestOf: query.ignoring,
                               intersection: intersection,
                               material: material,
                               id: id) else {
            return
        }

        results.append(hit)
    }
    
    mutating func attributeIds(_ idFactory: inout RaytracingElementIdFactory) {
        id = idFactory.makeId()
    }

    func queryScene(id: Int) -> RaytracingElement? {
        id == self.id ? self : nil
    }
}

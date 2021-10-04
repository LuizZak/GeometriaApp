struct EllipseRaytracingElement: RaytracingElement {
    var id: Int = 0
    var geometry: REllipse3D
    var material: RaytracingMaterial
    
    func raycast(query: RayQuery) -> RayQuery {
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
}

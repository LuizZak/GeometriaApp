struct GeometryRaytracingElement<T: Convex3Type>: RaytracingElement where T.Vector == RVector3D {
    var id: Int = 0
    var geometry: T
    var material: RaytracingMaterial
    
    func raycast(query: RayQuery) -> RayQuery {
        let intersection = query.intersect(geometry)
        guard let hit = RayHit(findingPointOfInterestOf: query.ignoring,
                               intersection: intersection,
                               id: id) else {
            return query
        }
        
        return query.withHit(hit)
    }
    
    mutating func attributeIds(_ idFactory: inout RaytracingElementIdFactory) {
        id = idFactory.makeId()
    }
}

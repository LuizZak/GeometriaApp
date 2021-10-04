struct CylinderRaytracingElement: RaytracingElement {
    var id: Int = 0
    var geometry: RCylinder3D
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

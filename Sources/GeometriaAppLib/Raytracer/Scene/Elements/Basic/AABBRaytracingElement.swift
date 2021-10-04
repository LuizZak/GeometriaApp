struct AABBRaytracingElement {
    var id: Int = 0
    var geometry: RAABB3D
    var material: Material
}

extension AABBRaytracingElement: RaytracingElement {
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
    
    @_transparent
    mutating func attributeIds(_ idFactory: inout RaytracingElementIdFactory) {
        id = idFactory.makeId()
    }

    @_transparent
    func queryScene(id: Int) -> RaytracingElement? {
        id == self.id ? self : nil
    }
}

extension AABBRaytracingElement: BoundedRaytracingElement {
    func makeBounds() -> RaytracingBounds {
        .makeBounds(for: geometry)
    }
}

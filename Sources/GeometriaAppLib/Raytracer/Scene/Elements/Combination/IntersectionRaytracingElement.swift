typealias IntersectionRaytracingElement<T0: RaytracingElement, T1: RaytracingElement> =
    IntersectionElement<T0, T1>

extension IntersectionRaytracingElement: RaytracingElement {
    @inlinable
    func raycast(query: RayQuery) -> RayQuery {
        if query.ignoring.shouldIgnoreFully(id: id) {
            return query
        }
        
        var local: [RayHit] = []

        raycast(query: query, results: &local)

        if let hit = local.first {
            return query.withHit(hit)
        }

        return query
    }

    @inlinable
    func raycast(query: RayQuery, results: inout [RayHit]) {
        if query.ignoring.shouldIgnoreFully(id: id) {
            return
        }
        
        let noHitQuery = query.withNilHit()

        var t0Hits: [RayHit] = []
        var t1Hits: [RayHit] = []
        t0.raycast(query: noHitQuery, results: &t0Hits)
        t1.raycast(query: noHitQuery, results: &t1Hits)

        var combined: [RayHitInfo] = []
        combined.append(contentsOf:
            t0Hits.map { .t0($0, $0.point.distanceSquared(to: query.ray.start)) }
        )
        combined.append(contentsOf:
            t1Hits.map { .t1($0, $0.point.distanceSquared(to: query.ray.start)) }
        )

        // Sort hit points by distance along the ray
        combined.sort {
            $0.distanceSquared < $1.distanceSquared
        }

        func isT0Included(_ index: Int) -> Bool {
            assert(combined[index].isT0, "isExcluded must be called on t0 hits")
            
            if index > 0 {
                for i in (0..<index).reversed() where !combined[i].isT0 {
                    return combined[i].state == .left
                }
            }
            if index < combined.count - 1 {
                for i in (index + 1)..<combined.count where !combined[i].isT0 {
                    return combined[i].state == .right
                }
            }
            return false
        }
        
        func isT1Included(_ index: Int) -> Bool {
            assert(!combined[index].isT0, "isIncluded must be called on t1 hits")
            
            if index > 0 {
                for i in (0..<index).reversed() where combined[i].isT0 {
                    return combined[i].state == .left
                }
            }
            if index < combined.count - 1 {
                for i in (index + 1)..<combined.count where combined[i].isT0 {
                    return combined[i].state == .right
                }
            }
            return false
        }
        
        var included: [RayHit] = []
        var index = 0
        
        // Sweep the list and exclude t0 hit points that are surrounded by 
        // opposing t1 points
        index = 0
        while index < combined.count {
            defer { index += 1 }
            let hit = combined[index]
            if hit.isT0 {
                if isT0Included(index) {
                    included.append(hit.asRayHit)
                }
            } else {
                if isT1Included(index) {
                    // Flip the reported direction of the hit (intersections on
                    // the subtracting geometry are actually flipped inside out)
                    var t1Hit = hit.asRayHit
                    t1Hit.hitDirection = t1Hit.hitDirection.inverted
                    included.append(t1Hit)
                }
            }
        }
        
        // TODO: Figure out better way to express material replacement
        // TODO: Maybe make IntersectionElement its own class of geometry with
        // TODO: unique ID and material support?
        results.append(contentsOf: included.map { hit in
            var hit = hit
            hit.id = id
            hit.material = materialId ?? t0Hits.first?.material ?? t1Hits.first?.material
            return hit
        })
    }
}

private enum RayHitInfo {
    case t0(RayHit, Double)
    case t1(RayHit, Double)

    var isT0: Bool {
        switch self {
        case .t0: return true
        case .t1: return false
        }
    }

    var hitDirection: RayHit.HitDirection {
        switch self {
        case .t0(let hit, _), .t1(let hit, _):
            return hit.hitDirection
        }
    }

    var distanceSquared: Double {
        switch self {
        case .t0(_, let dist), .t1(_, let dist):
            return dist
        }
    }

    var state: State {
        switch self {
        case .t0(let hit, _):
            return hit.hitDirection == .outside ? .left : .right
        case .t1(let hit, _):
            return hit.hitDirection == .outside ? .left : .right
        }
    }

    var asRayHit: RayHit {
        switch self {
        case .t0(let hit, _):
            return hit
        case .t1(let hit, _):
            return hit
        }
    }
}

private enum State {
    case left
    case right
}

private enum RayHitInfoFlag {
    /// Ray hit is set to be included in the result
    case included

    /// Ray hit is set to be excluded from the result
    case excluded
}

typealias UnionRaytracingElement<T0: RaytracingElement, T1: RaytracingElement> =
    UnionElement<T0, T1>

extension UnionRaytracingElement: RaytracingElement {
    @inlinable
    func raycast(query: RayQuery) -> RayQuery {
        guard !query.ignoring.shouldIgnoreFully(id: id) else {
            return query
        }
        
        // TODO: Optimize this step as we don't need to compute all intersections
        // TODO: to do this operation
        var local: [RayHit] = []
        raycast(query: query, results: &local)

        if let hit = local.first {
            return query.withHit(hit)
        }

        return query
    }

    @inlinable
    func raycast(query: RayQuery, results: inout [RayHit]) {
        guard !query.ignoring.shouldIgnoreFully(id: id) else {
            return
        }
        
        var noHitQuery = query.withNilHit()
        noHitQuery.ignoring = .none

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

        @_transparent
        func state(_ info: RayHitInfo) -> State {
            switch info {
            case .t0(let hit, _), 
                 .t1(let hit, _):
                return hit.hitDirection == .outside ? .left : .right
            }
        }

        @_transparent
        func isT0Included(_ index: Int) -> Bool {
            assert(combined[index].isT0, "isT0Included must be called on t0 hits")
            
            if index > 0 {
                for i in (0..<index).reversed() where !combined[i].isT0 {
                    return state(combined[i]) == .right
                }
            }
            if index < combined.count - 1 {
                for i in (index + 1)..<combined.count where !combined[i].isT0 {
                    return state(combined[i]) == .left
                }
            }
            return true
        }
        
        @_transparent
        func isT1Included(_ index: Int) -> Bool {
            assert(combined[index].isT1, "isT1Included must be called on t1 hits")
            
            if index > 0 {
                for i in (0..<index).reversed() where !combined[i].isT1 {
                    return state(combined[i]) == .right
                }
            }
            if index < combined.count - 1 {
                for i in (index + 1)..<combined.count where !combined[i].isT1 {
                    return state(combined[i]) == .left
                }
            }
            return true
        }
        
        var index = 0
        while index < combined.count {
            defer { index += 1 }
            let hit = combined[index]
            var rayHit = hit.asRayHit
            rayHit.id = id
            rayHit.material = material ?? t0Hits.first?.material ?? t1Hits.first?.material

            if query.ignoring.shouldIgnore(hit: rayHit) {
                continue
            }

            if hit.isT0 && isT0Included(index) {
                results.append(rayHit)
            }
            if hit.isT1 && isT1Included(index) {
                results.append(rayHit)
            }
        }
    }
}

private enum RayHitInfo {
    case t0(RayHit, Double)
    case t1(RayHit, Double)

    @_transparent
    var isT0: Bool {
        switch self {
        case .t0: return true
        case .t1: return false
        }
    }

    @_transparent
    var isT1: Bool {
        switch self {
        case .t0: return false
        case .t1: return true
        }
    }

    @_transparent
    var hitDirection: RayHit.HitDirection {
        switch self {
        case .t0(let hit, _), .t1(let hit, _):
            return hit.hitDirection
        }
    }

    @_transparent
    var distanceSquared: Double {
        switch self {
        case .t0(_, let dist), .t1(_, let dist):
            return dist
        }
    }

    @_transparent
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

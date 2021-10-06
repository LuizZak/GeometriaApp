typealias SubtractionRaytracingElement<T0: RaytracingElement, T1: RaytracingElement> =
    SubtractionElement<T0, T1>

extension SubtractionRaytracingElement: RaytracingElement {
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
        
        // For raytracing subtractions, any ray hit on the subtracted geometry 
        // that overlaps the second geometry is ignored. When this occurs, the 
        // hit is moved to the end of the subtracting geometry, unless that 
        // intersection itself is not contained within the subtracted geometry.

        var noHitQuery = query.withNilHit()
        noHitQuery.ignoring = .none

        // TODO: Fix RayQuery.ignoring for subtraction queries
        var t0Hits: [RayHit] = []
        t0.raycast(query: noHitQuery, results: &t0Hits)

        // If t0 is not intersected by the ray, it means we are no longer within
        // its bounds and thus there's no geometry left to subtract.
        if t0Hits.isEmpty {
            return
        }

        var t1Hits: [RayHit] = []
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
                    return combined[i].state == .right
                }
            }
            if index < combined.count - 1 {
                for i in (index + 1)..<combined.count where !combined[i].isT0 {
                    return combined[i].state == .left
                }
            }
            return true
        }
        
        func isT1Included(_ index: Int) -> Bool {
            assert(!combined[index].isT0, "isIncluded must be called on t1 hits")
            
            if index > 0 {
                for i in (0..<index).reversed() where combined[i].isT0 {
                    return combined[i].state == .right
                }
            }
            if index < combined.count - 1 {
                for i in (index + 1)..<combined.count where combined[i].isT0 {
                    return combined[i].state == .left
                }
            }
            return true
        }
        
        var included: [RayHit] = []
        var index = 0
        
        index = 0
        while index < combined.count {
            defer { index += 1 }
            let hit = combined[index]
            var rayHit = hit.asRayHit
            rayHit.id = id

            // Flip the reported direction of t1 hits (intersections on the 
            // subtracting geometry are actually flipped inside out)
            if !hit.isT0 {
                rayHit.hitDirection = rayHit.hitDirection.inverted
            }

            if query.ignoring.shouldIgnore(hit: rayHit) {
                continue
            }

            if hit.isT0 && isT0Included(index) {
                included.append(rayHit)
            } else if !hit.isT0 && isT1Included(index) {
                included.append(rayHit)
            }
        }
        
        // TODO: Figure out better way to express material replacement
        // TODO: Maybe make SubtractionElement its own class of geometry with
        // TODO: unique ID and material support?
        results.append(contentsOf: included.map { hit in
            var hit = hit
            hit.id = id
            hit.material = material ?? t0Hits[0].material
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
            return hit.hitDirection == .outside ? .right : .left
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

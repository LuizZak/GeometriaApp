typealias SubtractionRaytracingElement<T0: RaytracingElement, T1: RaytracingElement> =
    SubtractionElement<T0, T1>

extension SubtractionRaytracingElement: RaytracingElement {
    @inlinable
    func raycast(query: RayQuery) -> RayQuery {
        // For raytracing subtractions, any ray hit on the subtracted geometry and 
        // overlaps the second geometry is ignored. When this occurs, the hit
        // is moved to the end of the subtracting geometry, unless that intersection
        // itself is not contained within the subtracted geometry.
        var local: [RayHit] = []

        raycast(query: query, results: &local)

        if let hit = local.first {
            return query.withHit(hit)
        }

        return query
    }

    @inlinable
    func raycast(query: RayQuery, results: inout [RayHit]) {
        let noHitQuery = query.withNilHit()

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

        func isExcluded(_ index: Int) -> Bool {
            if index > 0 {
                for i in (0..<index).reversed() {
                    if !combined[i].isT0 && combined[i].state == .left {
                        return true
                    }
                }
            }
            if index < combined.count - 1 {
                for i in (index + 1)..<combined.count {
                    if !combined[i].isT0 && combined[i].state == .right {
                        return true
                    }
                }
            }
            return false
        }

        // Sweep the list and exclude t0 hit points that are surrounded by 
        // opposing t1 points
        var index = 0
        while index < combined.count {
            if combined[index].isT0 && isExcluded(index) {
                combined.remove(at: index)
            } else {
                index += 1
            }
        }

        // Now only include in the result any hit point that is followed by a
        // hit point of opposite direction
        var included: [RayHit] = []
        var previous: RayHitInfo?
        for info in combined {
            if let previous = previous {
                if previous.state == .left && info.state == .right || previous.state == .right && info.state == .left {
                    included.append(previous.asRayHit)
                    included.append(info.asRayHit)
                }
            }
            
            previous = info
        }
        
        results.append(contentsOf: included)
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
        case .t0(let hit, _), .t1(let hit, _):
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

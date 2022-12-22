@usableFromInline
enum RayHitInfo {
    case t0(RayHit, Double)
    case t1(RayHit, Double)

    @usableFromInline
    var distanceSquared: Double {
        switch self {
        case .t0(_, let dist), .t1(_, let dist):
            return dist
        }
    }

    @usableFromInline
    var asRayHit: RayHit {
        switch self {
        case .t0(let hit, _):
            return hit
        case .t1(let hit, _):
            return hit
        }
    }
}

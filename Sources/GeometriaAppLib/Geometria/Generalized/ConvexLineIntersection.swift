/// The result of a convex-line intersection test.
public enum ConvexLineIntersection<Vector: VectorType> {
    /// Represents the case where the line's boundaries are completely contained
    /// within the bounds of the convex shape.
    case contained
    
    /// Represents the case where the line crosses the bounds of the convex
    /// shape on a single vertex, or tangentially, in case of spheroids.
    case singlePoint(PointNormal<Vector>)
    
    /// Represents cases where the line starts outside the shape and crosses in
    /// before ending within the shape's bounds.
    case enter(PointNormal<Vector>)
    
    /// Represents cases where the line starts within the convex shape and
    /// intersects the boundaries on the way out.
    case exit(PointNormal<Vector>)
    
    /// Represents cases where the line crosses the convex shape twice: Once on
    /// the way in, and once again on the way out.
    case enterExit(PointNormal<Vector>, PointNormal<Vector>)
    
    /// Represents the case where no intersection occurs at any point.
    case noIntersection
    
    /// Returns a new ``ConvexLineIntersection`` where any ``PointNormal`` value
    /// is mapped by a provided closure before being stored back into the same
    /// enum case and returned.
    @inlinable
    public func mappingPointNormals(_ mapper: (PointNormal<Vector>, PointNormalKind) -> PointNormal<Vector>) -> ConvexLineIntersection<Vector> {
        
        switch self {
        case .contained:
            return .contained
        
        case .noIntersection:
            return .noIntersection
        
        case .singlePoint(let pointNormal):
            return .singlePoint(mapper(pointNormal, .singlePoint))
        
        case .enter(let pointNormal):
            return .enter(mapper(pointNormal, .enter))
        
        case .exit(let pointNormal):
            return .exit(mapper(pointNormal, .exit))
        
        case let .enterExit(p1, p2):
            return .enterExit(mapper(p1, .enter), mapper(p2, .exit))
        }
    }

    /// Returns a new ``ConvexLineIntersection`` where any ``PointNormal`` value
    /// is mapped and filtered by a provided closure, and the resulting intersection
    /// is updated to reflect the dropped intersection points.
    @inlinable
    public func filteringPointNormals(_ mapper: (PointNormal<Vector>, PointNormalKind) -> PointNormal<Vector>?) -> ConvexLineIntersection<Vector> {
        
        switch self {
        case .contained:
            return .contained
        
        case .noIntersection:
            return .noIntersection
        
        case .singlePoint(let pointNormal):
            guard let pointNormal = mapper(pointNormal, .singlePoint) else {
                return .noIntersection
            }

            return .singlePoint(pointNormal)
        
        case .enter(let pointNormal):
            guard let pointNormal = mapper(pointNormal, .enter) else {
                return .noIntersection
            }

            return .enter(pointNormal)
        
        case .exit(let pointNormal):
            guard let pointNormal = mapper(pointNormal, .exit) else {
                return .noIntersection
            }

            return .exit(pointNormal)
        
        case let .enterExit(p1, p2):
            let enter = mapper(p1, .enter)
            let exit = mapper(p2, .exit)

            switch (enter, exit) {
            case (let p1?, let p2?):
                return .enterExit(p1, p2)

            case (let p1?, nil):
                return .enter(p1)

            case (nil, let p2?):
                return .enter(p2)

            case (nil, nil):
                return .noIntersection
            }
        }
    }
    
    /// Returns a new ``ConvexLineIntersection`` where any ``PointNormal`` value
    /// is replaced by a provided closure before being stored back into the same
    /// enum case and returned.
    @inlinable
    public func replacingPointNormals<NewVector: VectorType>(_ mapper: (PointNormal<Vector>, PointNormalKind) -> PointNormal<NewVector>) -> ConvexLineIntersection<NewVector> {
        
        switch self {
        case .contained:
            return .contained
            
        case .noIntersection:
            return .noIntersection
            
        case .singlePoint(let pointNormal):
            return .singlePoint(mapper(pointNormal, .singlePoint))
            
        case .enter(let pointNormal):
            return .enter(mapper(pointNormal, .enter))
            
        case .exit(let pointNormal):
            return .exit(mapper(pointNormal, .exit))
            
        case let .enterExit(p1, p2):
            return .enterExit(mapper(p1, .enter), mapper(p2, .exit))
        }
    }
    
    /// Parameter passed along point normals in ``mappingPointNormals`` and
    /// ``replacingPointNormals`` to specify to the closure which kind of point
    /// normal was provided.
    public enum PointNormalKind {
        case singlePoint
        case enter
        case exit
    }
}

extension ConvexLineIntersection: Equatable where Vector: Equatable { }
extension ConvexLineIntersection: Hashable where Vector: Hashable { }

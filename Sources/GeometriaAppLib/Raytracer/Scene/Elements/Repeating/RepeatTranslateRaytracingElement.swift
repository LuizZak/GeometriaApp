#if canImport(Geometria)
import Geometria
#endif

public typealias RepeatTranslateRaytracingElement<T: RaytracingElement> = RepeatTranslateElement<T>

extension RepeatTranslateRaytracingElement: RaytracingElement {
    @inlinable
    public func raycast(query: consuming RayQuery) -> RayQuery {
        var current = query

        var index = 0
        while index < count {
            defer { index += 1 }
            
            current = element.raycast(query: current)
            current = current.translated(by: -translation)
        }

        let totalTranslation = translation * Double(count)
        
        return current.translated(by: totalTranslation)
    }

    @inlinable
    public func raycast(query: RayQuery, results: inout SortedRayHits) {
        var current = query

        var index = 0
        while index < count {
            defer { index += 1 }
            
            element.raycast(query: current, results: &results)
            current = current.translated(by: -translation)
        }
    }
    
    @inlinable
    public func contains(point: RVector3D) -> Bool {
        if count == 0 {
            return false
        }
        
        var current = point

        var index = 0
        while index < count {
            defer { index += 1 }
            
            if element.contains(point: point) {
                return true
            }
            
            current = current - translation
        }
        
        return false
    }
    
    // TODO: Handle cases where the ray intersects a single instance of the geometry but stays within the overall overlapped volume when repetition is applied.
    @inlinable
    public func fullyContainsRay(query: RayQuery) -> Bool {
        if count == 0 {
            return false
        }
        
        var current = query

        var index = 0
        while index < count {
            defer { index += 1 }
            
            if element.fullyContainsRay(query: query) {
                return true
            }
            
            current = current.translated(by: -translation)
        }
        
        return false
    }
}

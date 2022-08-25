typealias RepeatTranslateRaytracingElement<T: RaytracingElement> = RepeatTranslateElement<T>

extension RepeatTranslateRaytracingElement: RaytracingElement {
    @inlinable
    func raycast(query: RayQuery) -> RayQuery {
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
    func raycast(query: RayQuery, results: inout [RayHit]) {
        var current = query

        var index = 0
        while index < count {
            defer { index += 1 }
            
            element.raycast(query: current, results: &results)
            current = current.translated(by: -translation)
        }
    }
    
    func fullyContainsRay(query: RayQuery) -> Bool {
        if count == 0 {
            return false
        }
        
        var current = query

        var index = 0
        while index < count {
            defer { index += 1 }
            
            if !element.fullyContainsRay(query: query) {
                return false
            }
            
            current = current.translated(by: -translation)
        }
        
        return true
    }
}

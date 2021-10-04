typealias RepeatTranslateRaytracingElement<T: RaytracingElement> = RepeatTranslateElement<T>

extension RepeatTranslateRaytracingElement: RaytracingElement {
    @inlinable
    func raycast(query: RayQuery) -> RayQuery {
        var current = query
        let startRay = query.ray

        var index = 0
        while index < count {
            defer { index += 1 }
            
            var next = current
            next.ray = startRay.offsetBy(-translation * Double(index))

            current = element.raycast(query: next)
        }

        current.ray = startRay
        
        return current
    }

    func raycast(query: RayQuery, results: inout [RayHit]) {
        var current = query
        let startRay = query.ray

        var index = 0
        while index < count {
            defer { index += 1 }
            
            var next = current
            next.ray = startRay.offsetBy(-translation * Double(index))

            element.raycast(query: next, results: &results)

            current = next
        }
    }
}

public typealias TupleRaytracingElement2<T0: RaytracingElement, T1: RaytracingElement> =
    TupleElement2<T0, T1>

public typealias TupleRaytracingElement3<T0: RaytracingElement, T1: RaytracingElement, T2: RaytracingElement> =
    TupleElement3<T0, T1, T2>

public typealias TupleRaytracingElement4<T0: RaytracingElement, T1: RaytracingElement, T2: RaytracingElement, T3: RaytracingElement> =
    TupleElement4<T0, T1, T2, T3>

public typealias TupleRaytracingElement5<T0: RaytracingElement, T1: RaytracingElement, T2: RaytracingElement, T3: RaytracingElement, T4: RaytracingElement> =
    TupleElement5<T0, T1, T2, T3, T4>

public typealias TupleRaytracingElement6<T0: RaytracingElement, T1: RaytracingElement, T2: RaytracingElement, T3: RaytracingElement, T4: RaytracingElement, T5: RaytracingElement> =
    TupleElement6<T0, T1, T2, T3, T4, T5>

public typealias TupleRaytracingElement7<T0: RaytracingElement, T1: RaytracingElement, T2: RaytracingElement, T3: RaytracingElement, T4: RaytracingElement, T5: RaytracingElement, T6: RaytracingElement> =
    TupleElement7<T0, T1, T2, T3, T4, T5, T6>

public typealias TupleRaytracingElement8<T0: RaytracingElement, T1: RaytracingElement, T2: RaytracingElement, T3: RaytracingElement, T4: RaytracingElement, T5: RaytracingElement, T6: RaytracingElement, T7: RaytracingElement> =
    TupleElement8<T0, T1, T2, T3, T4, T5, T6, T7>

extension TupleRaytracingElement2: RaytracingElement {
    @inlinable
    public func raycast(query: consuming RayQuery) -> RayQuery {
        var query = query
        
        query = t0.raycast(query: query)
        query = t1.raycast(query: query)
        
        return query
    }

    @inlinable
    public func raycast(query: RayQuery, results: inout SortedRayHits) {
        t0.raycast(query: query, results: &results)
        t1.raycast(query: query, results: &results)
    }
    
    @inlinable
    public func fullyContainsRay(query: RayQuery) -> Bool {
        return t0.fullyContainsRay(query: query)
            && t1.fullyContainsRay(query: query)
    }
}

extension TupleRaytracingElement3: RaytracingElement {
    @inlinable
    public func raycast(query: consuming RayQuery) -> RayQuery {
        var query = query

        query = t0.raycast(query: query)
        query = t1.raycast(query: query)
        query = t2.raycast(query: query)

        return query
    }

    @inlinable
    public func raycast(query: RayQuery, results: inout SortedRayHits) {
        t0.raycast(query: query, results: &results)
        t1.raycast(query: query, results: &results)
        t2.raycast(query: query, results: &results)
    }
    
    @inlinable
    public func fullyContainsRay(query: RayQuery) -> Bool {
        return t0.fullyContainsRay(query: query)
            && t1.fullyContainsRay(query: query)
            && t2.fullyContainsRay(query: query)
    }
}

extension TupleRaytracingElement4: RaytracingElement {
    @inlinable
    public func raycast(query: consuming RayQuery) -> RayQuery {
        var query = query

        query = t0.raycast(query: query)
        query = t1.raycast(query: query)
        query = t2.raycast(query: query)
        query = t3.raycast(query: query)

        return query
    }

    @inlinable
    public func raycast(query: RayQuery, results: inout SortedRayHits) {
        t0.raycast(query: query, results: &results)
        t1.raycast(query: query, results: &results)
        t2.raycast(query: query, results: &results)
        t3.raycast(query: query, results: &results)
    }
    
    public func fullyContainsRay(query: RayQuery) -> Bool {
        return t0.fullyContainsRay(query: query)
            && t1.fullyContainsRay(query: query)
            && t2.fullyContainsRay(query: query)
            && t3.fullyContainsRay(query: query)
    }
}

extension TupleRaytracingElement5: RaytracingElement {
    @inlinable
    public func raycast(query: consuming RayQuery) -> RayQuery {
        var query = query

        query = t0.raycast(query: query)
        query = t1.raycast(query: query)
        query = t2.raycast(query: query)
        query = t3.raycast(query: query)
        query = t4.raycast(query: query)

        return query
    }

    @inlinable
    public func raycast(query: RayQuery, results: inout SortedRayHits) {
        t0.raycast(query: query, results: &results)
        t1.raycast(query: query, results: &results)
        t2.raycast(query: query, results: &results)
        t3.raycast(query: query, results: &results)
        t4.raycast(query: query, results: &results)
    }
    
    @inlinable
    public func fullyContainsRay(query: RayQuery) -> Bool {
        return t0.fullyContainsRay(query: query)
            && t1.fullyContainsRay(query: query)
            && t2.fullyContainsRay(query: query)
            && t3.fullyContainsRay(query: query)
            && t4.fullyContainsRay(query: query)
    }
}

extension TupleRaytracingElement6: RaytracingElement {
    @inlinable
    public func raycast(query: consuming RayQuery) -> RayQuery {
        var query = query

        query = t0.raycast(query: query)
        query = t1.raycast(query: query)
        query = t2.raycast(query: query)
        query = t3.raycast(query: query)
        query = t4.raycast(query: query)
        query = t5.raycast(query: query)

        return query
    }

    @inlinable
    public func raycast(query: RayQuery, results: inout SortedRayHits) {
        t0.raycast(query: query, results: &results)
        t1.raycast(query: query, results: &results)
        t2.raycast(query: query, results: &results)
        t3.raycast(query: query, results: &results)
        t4.raycast(query: query, results: &results)
        t5.raycast(query: query, results: &results)
    }
    
    @inlinable
    public func fullyContainsRay(query: RayQuery) -> Bool {
        return t0.fullyContainsRay(query: query)
            && t1.fullyContainsRay(query: query)
            && t2.fullyContainsRay(query: query)
            && t3.fullyContainsRay(query: query)
            && t4.fullyContainsRay(query: query)
            && t5.fullyContainsRay(query: query)
    }
}

extension TupleRaytracingElement7: RaytracingElement {
    @inlinable
    public func raycast(query: consuming RayQuery) -> RayQuery {
        var query = query

        query = t0.raycast(query: query)
        query = t1.raycast(query: query)
        query = t2.raycast(query: query)
        query = t3.raycast(query: query)
        query = t4.raycast(query: query)
        query = t5.raycast(query: query)
        query = t6.raycast(query: query)

        return query
    }

    @inlinable
    public func raycast(query: RayQuery, results: inout SortedRayHits) {
        t0.raycast(query: query, results: &results)
        t1.raycast(query: query, results: &results)
        t2.raycast(query: query, results: &results)
        t3.raycast(query: query, results: &results)
        t4.raycast(query: query, results: &results)
        t5.raycast(query: query, results: &results)
        t6.raycast(query: query, results: &results)
    }
    
    @inlinable
    public func fullyContainsRay(query: RayQuery) -> Bool {
        return t0.fullyContainsRay(query: query)
            && t1.fullyContainsRay(query: query)
            && t2.fullyContainsRay(query: query)
            && t3.fullyContainsRay(query: query)
            && t4.fullyContainsRay(query: query)
            && t5.fullyContainsRay(query: query)
            && t6.fullyContainsRay(query: query)
    }
}

extension TupleRaytracingElement8: RaytracingElement {
    @inlinable
    public func raycast(query: consuming RayQuery) -> RayQuery {
        var query = query

        query = t0.raycast(query: query)
        query = t1.raycast(query: query)
        query = t2.raycast(query: query)
        query = t3.raycast(query: query)
        query = t4.raycast(query: query)
        query = t5.raycast(query: query)
        query = t6.raycast(query: query)
        query = t7.raycast(query: query)

        return query
    }

    @inlinable
    public func raycast(query: RayQuery, results: inout SortedRayHits) {
        t0.raycast(query: query, results: &results)
        t1.raycast(query: query, results: &results)
        t2.raycast(query: query, results: &results)
        t3.raycast(query: query, results: &results)
        t4.raycast(query: query, results: &results)
        t5.raycast(query: query, results: &results)
        t6.raycast(query: query, results: &results)
        t7.raycast(query: query, results: &results)
    }
    
    @inlinable
    public func fullyContainsRay(query: RayQuery) -> Bool {
        return t0.fullyContainsRay(query: query)
            && t1.fullyContainsRay(query: query)
            && t2.fullyContainsRay(query: query)
            && t3.fullyContainsRay(query: query)
            && t4.fullyContainsRay(query: query)
            && t5.fullyContainsRay(query: query)
            && t6.fullyContainsRay(query: query)
            && t7.fullyContainsRay(query: query)
    }
}

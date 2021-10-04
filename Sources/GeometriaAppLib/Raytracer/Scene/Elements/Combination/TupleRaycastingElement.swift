struct TupleRaytracingElement2<T0: RaytracingElement, T1: RaytracingElement>: RaytracingElement {
    var t0: T0
    var t1: T1

    @inlinable
    func raycast(query: RayQuery) -> RayQuery {
        var query = query
        
        query = t0.raycast(query: query)
        query = t1.raycast(query: query)
        
        return query
    }

    func raycast(query: RayQuery, results: inout [RayHit]) {
        t0.raycast(query: query, results: &results)
        t1.raycast(query: query, results: &results)
    }
    
    mutating func attributeIds(_ idFactory: inout RaytracingElementIdFactory) {
        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
    }
}

struct TupleRaytracingElement3<T0: RaytracingElement, T1: RaytracingElement, T2: RaytracingElement>: RaytracingElement {
    var t0: T0
    var t1: T1
    var t2: T2

    @inlinable
    func raycast(query: RayQuery) -> RayQuery {
        var query = query

        query = t0.raycast(query: query)
        query = t1.raycast(query: query)
        query = t2.raycast(query: query)

        return query
    }

    func raycast(query: RayQuery, results: inout [RayHit]) {
        t0.raycast(query: query, results: &results)
        t1.raycast(query: query, results: &results)
        t2.raycast(query: query, results: &results)
    }
    
    mutating func attributeIds(_ idFactory: inout RaytracingElementIdFactory) {
        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
        t2.attributeIds(&idFactory)
    }
}

struct TupleRaytracingElement4<T0: RaytracingElement, T1: RaytracingElement, T2: RaytracingElement, T3: RaytracingElement>: RaytracingElement {
    var t0: T0
    var t1: T1
    var t2: T2
    var t3: T3

    @inlinable
    func raycast(query: RayQuery) -> RayQuery {
        var query = query

        query = t0.raycast(query: query)
        query = t1.raycast(query: query)
        query = t2.raycast(query: query)
        query = t3.raycast(query: query)

        return query
    }

    func raycast(query: RayQuery, results: inout [RayHit]) {
        t0.raycast(query: query, results: &results)
        t1.raycast(query: query, results: &results)
        t2.raycast(query: query, results: &results)
        t3.raycast(query: query, results: &results)
    }
    
    mutating func attributeIds(_ idFactory: inout RaytracingElementIdFactory) {
        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
        t2.attributeIds(&idFactory)
        t3.attributeIds(&idFactory)
    }
}

struct TupleRaytracingElement5<T0: RaytracingElement, T1: RaytracingElement, T2: RaytracingElement, T3: RaytracingElement, T4: RaytracingElement>: RaytracingElement {
    var t0: T0
    var t1: T1
    var t2: T2
    var t3: T3
    var t4: T4

    @inlinable
    func raycast(query: RayQuery) -> RayQuery {
        var query = query

        query = t0.raycast(query: query)
        query = t1.raycast(query: query)
        query = t2.raycast(query: query)
        query = t3.raycast(query: query)
        query = t4.raycast(query: query)

        return query
    }

    func raycast(query: RayQuery, results: inout [RayHit]) {
        t0.raycast(query: query, results: &results)
        t1.raycast(query: query, results: &results)
        t2.raycast(query: query, results: &results)
        t3.raycast(query: query, results: &results)
        t4.raycast(query: query, results: &results)
    }
    
    mutating func attributeIds(_ idFactory: inout RaytracingElementIdFactory) {
        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
        t2.attributeIds(&idFactory)
        t3.attributeIds(&idFactory)
        t4.attributeIds(&idFactory)
    }
}

struct TupleRaytracingElement6<T0: RaytracingElement, T1: RaytracingElement, T2: RaytracingElement, T3: RaytracingElement, T4: RaytracingElement, T5: RaytracingElement>: RaytracingElement {
    var t0: T0
    var t1: T1
    var t2: T2
    var t3: T3
    var t4: T4
    var t5: T5

    @inlinable
    func raycast(query: RayQuery) -> RayQuery {
        var query = query

        query = t0.raycast(query: query)
        query = t1.raycast(query: query)
        query = t2.raycast(query: query)
        query = t3.raycast(query: query)
        query = t4.raycast(query: query)
        query = t5.raycast(query: query)

        return query
    }

    func raycast(query: RayQuery, results: inout [RayHit]) {
        t0.raycast(query: query, results: &results)
        t1.raycast(query: query, results: &results)
        t2.raycast(query: query, results: &results)
        t3.raycast(query: query, results: &results)
        t4.raycast(query: query, results: &results)
        t5.raycast(query: query, results: &results)
    }
    
    mutating func attributeIds(_ idFactory: inout RaytracingElementIdFactory) {
        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
        t2.attributeIds(&idFactory)
        t3.attributeIds(&idFactory)
        t4.attributeIds(&idFactory)
        t5.attributeIds(&idFactory)
    }
}

struct TupleRaytracingElement7<T0: RaytracingElement, T1: RaytracingElement, T2: RaytracingElement, T3: RaytracingElement, T4: RaytracingElement, T5: RaytracingElement, T6: RaytracingElement>: RaytracingElement {
    var t0: T0
    var t1: T1
    var t2: T2
    var t3: T3
    var t4: T4
    var t5: T5
    var t6: T6

    @inlinable
    func raycast(query: RayQuery) -> RayQuery {
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

    func raycast(query: RayQuery, results: inout [RayHit]) {
        t0.raycast(query: query, results: &results)
        t1.raycast(query: query, results: &results)
        t2.raycast(query: query, results: &results)
        t3.raycast(query: query, results: &results)
        t4.raycast(query: query, results: &results)
        t5.raycast(query: query, results: &results)
        t6.raycast(query: query, results: &results)
    }
    
    mutating func attributeIds(_ idFactory: inout RaytracingElementIdFactory) {
        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
        t2.attributeIds(&idFactory)
        t3.attributeIds(&idFactory)
        t4.attributeIds(&idFactory)
        t5.attributeIds(&idFactory)
        t6.attributeIds(&idFactory)
    }
}

struct TupleRaytracingElement8<T0: RaytracingElement, T1: RaytracingElement, T2: RaytracingElement, T3: RaytracingElement, T4: RaytracingElement, T5: RaytracingElement, T6: RaytracingElement, T7: RaytracingElement>: RaytracingElement {
    var t0: T0
    var t1: T1
    var t2: T2
    var t3: T3
    var t4: T4
    var t5: T5
    var t6: T6
    var t7: T7

    @inlinable
    func raycast(query: RayQuery) -> RayQuery {
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

    func raycast(query: RayQuery, results: inout [RayHit]) {
        t0.raycast(query: query, results: &results)
        t1.raycast(query: query, results: &results)
        t2.raycast(query: query, results: &results)
        t3.raycast(query: query, results: &results)
        t4.raycast(query: query, results: &results)
        t5.raycast(query: query, results: &results)
        t6.raycast(query: query, results: &results)
        t7.raycast(query: query, results: &results)
    }
    
    mutating func attributeIds(_ idFactory: inout RaytracingElementIdFactory) {
        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
        t2.attributeIds(&idFactory)
        t3.attributeIds(&idFactory)
        t4.attributeIds(&idFactory)
        t5.attributeIds(&idFactory)
        t6.attributeIds(&idFactory)
        t7.attributeIds(&idFactory)
    }
}

typealias TupleRaytracingElement2<T0, T1> =
    TupleElement2<T0, T1> where
        T0: RaytracingElement,
        T1: RaytracingElement

typealias TupleRaytracingElement3<T0, T1, T2> =
    TupleElement3<T0, T1, T2> where
        T0: RaytracingElement,
        T1: RaytracingElement,
        T2: RaytracingElement

typealias TupleRaytracingElement4<T0, T1, T2, T3> =
    TupleElement4<T0, T1, T2, T3> where
        T0: RaytracingElement,
        T1: RaytracingElement,
        T2: RaytracingElement,
        T3: RaytracingElement

typealias TupleRaytracingElement5<T0, T1, T2, T3, T4> =
    TupleElement5<T0, T1, T2, T3, T4> where
        T0: RaytracingElement,
        T1: RaytracingElement,
        T2: RaytracingElement,
        T3: RaytracingElement,
        T4: RaytracingElement

typealias TupleRaytracingElement6<T0, T1, T2, T3, T4, T5> =
    TupleElement6<T0, T1, T2, T3, T4, T5> where
        T0: RaytracingElement,
        T1: RaytracingElement,
        T2: RaytracingElement,
        T3: RaytracingElement,
        T4: RaytracingElement,
        T5: RaytracingElement

typealias TupleRaytracingElement7<T0, T1, T2, T3, T4, T5, T6> =
    TupleElement7<T0, T1, T2, T3, T4, T5, T6> where
        T0: RaytracingElement,
        T1: RaytracingElement,
        T2: RaytracingElement,
        T3: RaytracingElement,
        T4: RaytracingElement,
        T5: RaytracingElement,
        T6: RaytracingElement

typealias TupleRaytracingElement8<T0, T1, T2, T3, T4, T5, T6, T7> =
    TupleElement8<T0, T1, T2, T3, T4, T5, T6, T7> where
        T0: RaytracingElement,
        T1: RaytracingElement,
        T2: RaytracingElement,
        T3: RaytracingElement,
        T4: RaytracingElement,
        T5: RaytracingElement,
        T6: RaytracingElement,
        T7: RaytracingElement

extension TupleRaytracingElement2: RaytracingElement {
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

    func queryScene(id: Int) -> RaytracingElement? {
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }

        return nil
    }
}

extension TupleRaytracingElement3: RaytracingElement {
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

    func queryScene(id: Int) -> RaytracingElement? {
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }
        if let el = t2.queryScene(id: id) { return el }

        return nil
    }
}

extension TupleRaytracingElement4: RaytracingElement {
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

    func queryScene(id: Int) -> RaytracingElement? {
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }
        if let el = t2.queryScene(id: id) { return el }
        if let el = t3.queryScene(id: id) { return el }

        return nil
    }
}

extension TupleRaytracingElement5: RaytracingElement {
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

    func queryScene(id: Int) -> RaytracingElement? {
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }
        if let el = t2.queryScene(id: id) { return el }
        if let el = t3.queryScene(id: id) { return el }
        if let el = t4.queryScene(id: id) { return el }

        return nil
    }
}

extension TupleRaytracingElement6: RaytracingElement {
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

    func queryScene(id: Int) -> RaytracingElement? {
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }
        if let el = t2.queryScene(id: id) { return el }
        if let el = t3.queryScene(id: id) { return el }
        if let el = t4.queryScene(id: id) { return el }
        if let el = t5.queryScene(id: id) { return el }

        return nil
    }
}

extension TupleRaytracingElement7: RaytracingElement {
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

    func queryScene(id: Int) -> RaytracingElement? {
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }
        if let el = t2.queryScene(id: id) { return el }
        if let el = t3.queryScene(id: id) { return el }
        if let el = t4.queryScene(id: id) { return el }
        if let el = t5.queryScene(id: id) { return el }
        if let el = t6.queryScene(id: id) { return el }

        return nil
    }
}

extension TupleRaytracingElement8: RaytracingElement {
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

    func queryScene(id: Int) -> RaytracingElement? {
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }
        if let el = t2.queryScene(id: id) { return el }
        if let el = t3.queryScene(id: id) { return el }
        if let el = t4.queryScene(id: id) { return el }
        if let el = t5.queryScene(id: id) { return el }
        if let el = t6.queryScene(id: id) { return el }
        if let el = t7.queryScene(id: id) { return el }

        return nil
    }
}

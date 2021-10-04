struct TupleElement2<T0: Element, T1: Element> {
    var t0: T0
    var t1: T1
}

struct TupleElement3<T0: Element, T1: Element, T2: Element> {
    var t0: T0
    var t1: T1
    var t2: T2
}

struct TupleElement4<T0: Element, T1: Element, T2: Element, T3: Element> {
    var t0: T0
    var t1: T1
    var t2: T2
    var t3: T3
}

struct TupleElement5<T0: Element, T1: Element, T2: Element, T3: Element, T4: Element> {
    var t0: T0
    var t1: T1
    var t2: T2
    var t3: T3
    var t4: T4
}

struct TupleElement6<T0: Element, T1: Element, T2: Element, T3: Element, T4: Element, T5: Element> {
    var t0: T0
    var t1: T1
    var t2: T2
    var t3: T3
    var t4: T4
    var t5: T5
}

struct TupleElement7<T0: Element, T1: Element, T2: Element, T3: Element, T4: Element, T5: Element, T6: Element> {
    var t0: T0
    var t1: T1
    var t2: T2
    var t3: T3
    var t4: T4
    var t5: T5
    var t6: T6
}

struct TupleElement8<T0: Element, T1: Element, T2: Element, T3: Element, T4: Element, T5: Element, T6: Element, T7: Element> {
    var t0: T0
    var t1: T1
    var t2: T2
    var t3: T3
    var t4: T4
    var t5: T5
    var t6: T6
    var t7: T7
}


extension TupleElement2: Element {
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
    }

    func queryScene(id: Int) -> Element? {
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }

        return nil
    }
}

extension TupleElement3: Element {
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
        t2.attributeIds(&idFactory)
    }

    func queryScene(id: Int) -> Element? {
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }
        if let el = t2.queryScene(id: id) { return el }

        return nil
    }
}

extension TupleElement4: Element {
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
        t2.attributeIds(&idFactory)
        t3.attributeIds(&idFactory)
    }

    func queryScene(id: Int) -> Element? {
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }
        if let el = t2.queryScene(id: id) { return el }
        if let el = t3.queryScene(id: id) { return el }

        return nil
    }
}

extension TupleElement5: Element {
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
        t2.attributeIds(&idFactory)
        t3.attributeIds(&idFactory)
        t4.attributeIds(&idFactory)
    }

    func queryScene(id: Int) -> Element? {
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }
        if let el = t2.queryScene(id: id) { return el }
        if let el = t3.queryScene(id: id) { return el }
        if let el = t4.queryScene(id: id) { return el }

        return nil
    }
}

extension TupleElement6: Element {
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
        t2.attributeIds(&idFactory)
        t3.attributeIds(&idFactory)
        t4.attributeIds(&idFactory)
        t5.attributeIds(&idFactory)
    }

    func queryScene(id: Int) -> Element? {
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }
        if let el = t2.queryScene(id: id) { return el }
        if let el = t3.queryScene(id: id) { return el }
        if let el = t4.queryScene(id: id) { return el }
        if let el = t5.queryScene(id: id) { return el }

        return nil
    }
}

extension TupleElement7: Element {
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
        t2.attributeIds(&idFactory)
        t3.attributeIds(&idFactory)
        t4.attributeIds(&idFactory)
        t5.attributeIds(&idFactory)
        t6.attributeIds(&idFactory)
    }

    func queryScene(id: Int) -> Element? {
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

extension TupleElement8: Element {
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
        t2.attributeIds(&idFactory)
        t3.attributeIds(&idFactory)
        t4.attributeIds(&idFactory)
        t5.attributeIds(&idFactory)
        t6.attributeIds(&idFactory)
        t7.attributeIds(&idFactory)
    }

    func queryScene(id: Int) -> Element? {
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

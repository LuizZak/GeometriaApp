/* TODO: Ideally this would be implemented as:
struct TupleElement<T...> {
    var t: T...
}

or, with non-variadic generics:

struct TupleElement<T> {
    var t: T
}

extension<T0: Element, T1: Element> TupleElement<(T0, T1)>: Element {
    ...
}
extension<T0: Element, T1: Element, T2: Element> TupleElement<(T0, T1, T2: Element)>: Element {
    ...
}

but do it with multiple tuples for now for performance reasons.
*/

public struct TupleElement2<T0: Element, T1: Element>: TupleElementType {
    public var id: Element.Id = 0
    public var t0: T0
    public var t1: T1

    public var elements: [Element] { [t0, t1] }

    public init(id: Element.Id = 0, t0: T0, t1: T1) {
        self.id = id
        self.t0 = t0
        self.t1 = t1
    }
}

public struct TupleElement3<T0: Element, T1: Element, T2: Element>: TupleElementType {
    public var id: Element.Id = 0
    public var t0: T0
    public var t1: T1
    public var t2: T2

    public var elements: [Element] { [t0, t1, t2] }

    public init(id: Element.Id = 0, t0: T0, t1: T1, t2: T2) {
        self.id = id
        self.t0 = t0
        self.t1 = t1
        self.t2 = t2
    }
}

public struct TupleElement4<T0: Element, T1: Element, T2: Element, T3: Element>: TupleElementType {
    public var id: Element.Id = 0
    public var t0: T0
    public var t1: T1
    public var t2: T2
    public var t3: T3

    public var elements: [Element] { [t0, t1, t2, t3] }

    public init(id: Element.Id = 0, t0: T0, t1: T1, t2: T2, t3: T3) {
        self.id = id
        self.t0 = t0
        self.t1 = t1
        self.t2 = t2
        self.t3 = t3
    }
}

public struct TupleElement5<T0: Element, T1: Element, T2: Element, T3: Element, T4: Element>: TupleElementType {
    public var id: Element.Id = 0
    public var t0: T0
    public var t1: T1
    public var t2: T2
    public var t3: T3
    public var t4: T4

    public var elements: [Element] { [t0, t1, t2, t3, t4] }

    public init(id: Element.Id = 0, t0: T0, t1: T1, t2: T2, t3: T3, t4: T4) {
        self.id = id
        self.t0 = t0
        self.t1 = t1
        self.t2 = t2
        self.t3 = t3
        self.t4 = t4
    }
}

public struct TupleElement6<T0: Element, T1: Element, T2: Element, T3: Element, T4: Element, T5: Element>: TupleElementType {
    public var id: Element.Id = 0
    public var t0: T0
    public var t1: T1
    public var t2: T2
    public var t3: T3
    public var t4: T4
    public var t5: T5

    public var elements: [Element] { [t0, t1, t2, t3, t4, t5] }

    public init(id: Element.Id = 0, t0: T0, t1: T1, t2: T2, t3: T3, t4: T4, t5: T5) {
        self.id = id
        self.t0 = t0
        self.t1 = t1
        self.t2 = t2
        self.t3 = t3
        self.t4 = t4
        self.t5 = t5
    }
}

public struct TupleElement7<T0: Element, T1: Element, T2: Element, T3: Element, T4: Element, T5: Element, T6: Element>: TupleElementType {
    public var id: Element.Id = 0
    public var t0: T0
    public var t1: T1
    public var t2: T2
    public var t3: T3
    public var t4: T4
    public var t5: T5
    public var t6: T6

    public var elements: [Element] { [t0, t1, t2, t3, t4, t5, t6] }

    public init(id: Element.Id = 0, t0: T0, t1: T1, t2: T2, t3: T3, t4: T4, t5: T5, t6: T6) {
        self.id = id
        self.t0 = t0
        self.t1 = t1
        self.t2 = t2
        self.t3 = t3
        self.t4 = t4
        self.t5 = t5
        self.t6 = t6
    }
}

public struct TupleElement8<T0: Element, T1: Element, T2: Element, T3: Element, T4: Element, T5: Element, T6: Element, T7: Element>: TupleElementType {
    public var id: Element.Id = 0
    public var t0: T0
    public var t1: T1
    public var t2: T2
    public var t3: T3
    public var t4: T4
    public var t5: T5
    public var t6: T6
    public var t7: T7

    public var elements: [Element] { [t0, t1, t2, t3, t4, t5, t6, t7] }

    public init(id: Element.Id = 0, t0: T0, t1: T1, t2: T2, t3: T3, t4: T4, t5: T5, t6: T6, t7: T7) {
        self.id = id
        self.t0 = t0
        self.t1 = t1
        self.t2 = t2
        self.t3 = t3
        self.t4 = t4
        self.t5 = t5
        self.t6 = t6
        self.t7 = t7
    }
}


extension TupleElement2: Element {
    @inlinable
    public mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()

        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
    }

    @inlinable
    public func queryScene(id: Element.Id) -> Element? {
        if id == self.id { return self }
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }

        return nil
    }

    public func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension TupleElement3: Element {
    @inlinable
    public mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()

        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
        t2.attributeIds(&idFactory)
    }

    @inlinable
    public func queryScene(id: Element.Id) -> Element? {
        if id == self.id { return self }
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }
        if let el = t2.queryScene(id: id) { return el }

        return nil
    }

    public func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension TupleElement4: Element {
    @inlinable
    public mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()

        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
        t2.attributeIds(&idFactory)
        t3.attributeIds(&idFactory)
    }

    @inlinable
    public func queryScene(id: Element.Id) -> Element? {
        if id == self.id { return self }
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }
        if let el = t2.queryScene(id: id) { return el }
        if let el = t3.queryScene(id: id) { return el }

        return nil
    }

    public func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension TupleElement5: Element {
    @inlinable
    public mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()

        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
        t2.attributeIds(&idFactory)
        t3.attributeIds(&idFactory)
        t4.attributeIds(&idFactory)
    }

    @inlinable
    public func queryScene(id: Element.Id) -> Element? {
        if id == self.id { return self }
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }
        if let el = t2.queryScene(id: id) { return el }
        if let el = t3.queryScene(id: id) { return el }
        if let el = t4.queryScene(id: id) { return el }

        return nil
    }

    public func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension TupleElement6: Element {
    @inlinable
    public mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()

        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
        t2.attributeIds(&idFactory)
        t3.attributeIds(&idFactory)
        t4.attributeIds(&idFactory)
        t5.attributeIds(&idFactory)
    }

    @inlinable
    public func queryScene(id: Element.Id) -> Element? {
        if id == self.id { return self }
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }
        if let el = t2.queryScene(id: id) { return el }
        if let el = t3.queryScene(id: id) { return el }
        if let el = t4.queryScene(id: id) { return el }
        if let el = t5.queryScene(id: id) { return el }

        return nil
    }

    public func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension TupleElement7: Element {
    @inlinable
    public mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()

        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
        t2.attributeIds(&idFactory)
        t3.attributeIds(&idFactory)
        t4.attributeIds(&idFactory)
        t5.attributeIds(&idFactory)
        t6.attributeIds(&idFactory)
    }

    @inlinable
    public func queryScene(id: Element.Id) -> Element? {
        if id == self.id { return self }
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }
        if let el = t2.queryScene(id: id) { return el }
        if let el = t3.queryScene(id: id) { return el }
        if let el = t4.queryScene(id: id) { return el }
        if let el = t5.queryScene(id: id) { return el }
        if let el = t6.queryScene(id: id) { return el }

        return nil
    }

    public func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension TupleElement8: Element {
    @inlinable
    public mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()

        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
        t2.attributeIds(&idFactory)
        t3.attributeIds(&idFactory)
        t4.attributeIds(&idFactory)
        t5.attributeIds(&idFactory)
        t6.attributeIds(&idFactory)
        t7.attributeIds(&idFactory)
    }

    @inlinable
    public func queryScene(id: Element.Id) -> Element? {
        if id == self.id { return self }
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

    public func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

public typealias TupleRaymarchingElement2<T0: RaymarchingElement, T1: RaymarchingElement> =
    TupleElement2<T0, T1>

public typealias TupleRaymarchingElement3<T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement> =
    TupleElement3<T0, T1, T2>

public typealias TupleRaymarchingElement4<T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement> =
    TupleElement4<T0, T1, T2, T3>

public typealias TupleRaymarchingElement5<T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement, T4: RaymarchingElement> =
    TupleElement5<T0, T1, T2, T3, T4>

public typealias TupleRaymarchingElement6<T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement, T4: RaymarchingElement, T5: RaymarchingElement> =
    TupleElement6<T0, T1, T2, T3, T4, T5>

public typealias TupleRaymarchingElement7<T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement, T4: RaymarchingElement, T5: RaymarchingElement, T6: RaymarchingElement> =
    TupleElement7<T0, T1, T2, T3, T4, T5, T6>

public typealias TupleRaymarchingElement8<T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement, T4: RaymarchingElement, T5: RaymarchingElement, T6: RaymarchingElement, T7: RaymarchingElement> =
    TupleElement8<T0, T1, T2, T3, T4, T5, T6, T7>

/* Currently the code below is not implementable because of a compiler issue that is present in Swift 5.9 but not on the nightly build, reproduced as follow:
protocol Base {
    func foo()
}

protocol Specialized: Base {
    func bar()
}

struct Tuple<each T: Base> {
    var t: (repeat each T)
}

struct Tuple2<T0: Base, T1: Base> {
    var t0: T0
    var t1: T1
}

typealias SpecializedTuple<each T: Specialized> = Tuple<repeat each T>
typealias SpecializedTuple2<T0: Specialized, T1: Specialized> = Tuple2<T0, T1>

extension SpecializedTuple {
    func baz() {
        repeat (each t).foo()
        repeat (each t).bar() // Error: value of type 'τ_1_0' has no member 'bar'
    }
}

extension SpecializedTuple2 {
    func baz() {
        t0.foo()
        t1.foo()

        t0.bar()
        t1.bar()
    }
}
*/

/*
#if VARIADIC_TUPLE_ELEMENT

public typealias TupleRaymarchingElement<each T: RaymarchingElement> = TupleElement<repeat each T>

extension TupleRaymarchingElement: RaymarchingElement {
    @inlinable
    public func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        repeat current = (each t).signedDistance(to: point, current: current)

        return current
    }

    public func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

#endif
*/

extension TupleRaymarchingElement2: RaymarchingElement {
    @inlinable
    public func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        current = t0.signedDistance(to: point, current: current)
        current = t1.signedDistance(to: point, current: current)

        return current
    }

    public func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension TupleRaymarchingElement3: RaymarchingElement {
    @inlinable
    public func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        current = t0.signedDistance(to: point, current: current)
        current = t1.signedDistance(to: point, current: current)
        current = t2.signedDistance(to: point, current: current)

        return current
    }

    public func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension TupleRaymarchingElement4: RaymarchingElement {
    @inlinable
    public func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        current = t0.signedDistance(to: point, current: current)
        current = t1.signedDistance(to: point, current: current)
        current = t2.signedDistance(to: point, current: current)
        current = t3.signedDistance(to: point, current: current)

        return current
    }

    public func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension TupleRaymarchingElement5: RaymarchingElement {
    @inlinable
    public func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        current = t0.signedDistance(to: point, current: current)
        current = t1.signedDistance(to: point, current: current)
        current = t2.signedDistance(to: point, current: current)
        current = t3.signedDistance(to: point, current: current)
        current = t4.signedDistance(to: point, current: current)

        return current
    }

    public func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension TupleRaymarchingElement6: RaymarchingElement {
    @inlinable
    public func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        current = t0.signedDistance(to: point, current: current)
        current = t1.signedDistance(to: point, current: current)
        current = t2.signedDistance(to: point, current: current)
        current = t3.signedDistance(to: point, current: current)
        current = t4.signedDistance(to: point, current: current)
        current = t5.signedDistance(to: point, current: current)

        return current
    }

    public func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension TupleRaymarchingElement7: RaymarchingElement {
    @inlinable
    public func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        current = t0.signedDistance(to: point, current: current)
        current = t1.signedDistance(to: point, current: current)
        current = t2.signedDistance(to: point, current: current)
        current = t3.signedDistance(to: point, current: current)
        current = t4.signedDistance(to: point, current: current)
        current = t5.signedDistance(to: point, current: current)
        current = t6.signedDistance(to: point, current: current)

        return current
    }

    public func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension TupleRaymarchingElement8: RaymarchingElement {
    @inlinable
    public func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        current = t0.signedDistance(to: point, current: current)
        current = t1.signedDistance(to: point, current: current)
        current = t2.signedDistance(to: point, current: current)
        current = t3.signedDistance(to: point, current: current)
        current = t4.signedDistance(to: point, current: current)
        current = t5.signedDistance(to: point, current: current)
        current = t6.signedDistance(to: point, current: current)
        current = t7.signedDistance(to: point, current: current)

        return current
    }

    public func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

public struct AnyRaymarchingBoundedElement {
    public var element: RaymarchingBoundedElement
    
    public init<T: RaymarchingBoundedElement>(_ element: T) {
        self.element = element
    }
    
    public init?(_ anyElement: AnyRaymarchingElement) {
        guard let element = anyElement.element as? RaymarchingBoundedElement else {
            return nil
        }

        self.element = element
    }
    
    public init?(_ anyElement: AnyBoundedElement) {
        guard let element = anyElement.element as? RaymarchingBoundedElement else {
            return nil
        }

        self.element = element
    }
    
    public init?(_ anyElement: AnyElement) {
        guard let element = anyElement.element as? RaymarchingBoundedElement else {
            return nil
        }

        self.element = element
    }
}

extension AnyRaymarchingBoundedElement: Element {
    public var id: Int {
        get {
            element.id
        }
        set {
            element.id = newValue
        }
    }

    @_transparent
    public mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        element.attributeIds(&idFactory)
    }

    @_transparent
    public func queryScene(id: Int) -> Element? {
        element.queryScene(id: id)
    }

    public func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        element.accept(visitor)
    }
}

extension AnyRaymarchingBoundedElement: BoundedElement {
    public func makeBounds() -> ElementBounds {
        return element.makeBounds()
    }
}

extension AnyRaymarchingBoundedElement: RaymarchingElement {
    public func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        element.signedDistance(to: point, current: current)
    }

    public func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        element.accept(visitor)
    }
}

struct AnyBoundedRaymarchingElement {
    var element: BoundedRaymarchingElement
    
    init<T: BoundedRaymarchingElement>(_ element: T) {
        self.element = element
    }
    
    init?(_ anyElement: AnyRaymarchingElement) {
        guard let element = anyElement.element as? BoundedRaymarchingElement else {
            return nil
        }

        self.element = element
    }
    
    init?(_ anyElement: AnyBoundedElement) {
        guard let element = anyElement.element as? BoundedRaymarchingElement else {
            return nil
        }

        self.element = element
    }
    
    init?(_ anyElement: AnyElement) {
        guard let element = anyElement.element as? BoundedRaymarchingElement else {
            return nil
        }

        self.element = element
    }
}

extension AnyBoundedRaymarchingElement: Element {
    var id: Int {
        get {
            element.id
        }
        set {
            element.id = newValue
        }
    }

    @_transparent
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        element.attributeIds(&idFactory)
    }

    @_transparent
    func queryScene(id: Int) -> Element? {
        element.queryScene(id: id)
    }

    func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        element.accept(visitor)
    }
}

extension AnyBoundedRaymarchingElement: BoundedElement {
    func makeBounds() -> ElementBounds {
        return element.makeBounds()
    }
}

extension AnyBoundedRaymarchingElement: RaymarchingElement {
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        element.signedDistance(to: point, current: current)
    }

    func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        element.accept(visitor)
    }
}

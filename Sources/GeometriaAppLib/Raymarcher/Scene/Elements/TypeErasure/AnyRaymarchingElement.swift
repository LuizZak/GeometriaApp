struct AnyRaymarchingElement {
    var element: RaymarchingElement
    
    init<T: RaymarchingElement>(_ element: T) {
        self.element = element
    }
    
    init?(_ anyElement: AnyElement) {
        guard let element = anyElement.element as? RaymarchingElement else {
            return nil
        }

        self.element = element
    }
}

extension AnyRaymarchingElement: Element {
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

extension AnyRaymarchingElement: RaymarchingElement {
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        element.signedDistance(to: point, current: current)
    }

    func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        element.accept(visitor)
    }
}

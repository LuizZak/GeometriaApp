struct AnyBoundedRaymarchingElement {
    private var _element: BoundedRaymarchingElement
    
    init<T: BoundedRaymarchingElement>(_ element: T) {
        _element = element
    }
}

extension AnyBoundedRaymarchingElement: Element {
    var id: Int {
        get {
            _element.id
        }
        set {
            _element.id = newValue
        }
    }

    @_transparent
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        _element.attributeIds(&idFactory)
    }

    @_transparent
    func queryScene(id: Int) -> Element? {
        _element.queryScene(id: id)
    }

    func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        _element.accept(visitor)
    }
}

extension AnyBoundedRaymarchingElement: BoundedElement {
    func makeBounds() -> ElementBounds {
        return _element.makeBounds()
    }
}

extension AnyBoundedRaymarchingElement: RaymarchingElement {
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        _element.signedDistance(to: point, current: current)
    }

    func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        _element.accept(visitor)
    }
}

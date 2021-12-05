struct AnyRaytracingElement {
    private var _element: RaytracingElement
    
    init<T: RaytracingElement>(_ element: T) {
        _element = element
    }
}

extension AnyRaytracingElement: Element {
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

extension AnyRaytracingElement: RaytracingElement {
    func raycast(query: RayQuery) -> RayQuery {
        _element.raycast(query: query)
    }
    func raycast(query: RayQuery, results: inout [RayHit]) {
        _element.raycast(query: query, results: &results)
    }
}

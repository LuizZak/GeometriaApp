struct AnyRaytracingElement {
    var element: RaytracingElement
    
    init<T: RaytracingElement>(_ element: T) {
        self.element = element
    }
    
    init?(_ anyElement: AnyElement) {
        guard let element = anyElement.element as? RaytracingElement else {
            return nil
        }

        self.element = element
    }
}

extension AnyRaytracingElement: Element {
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

extension AnyRaytracingElement: RaytracingElement {
    func raycast(query: RayQuery) -> RayQuery {
        element.raycast(query: query)
    }
    func raycast(query: RayQuery, results: inout [RayHit]) {
        element.raycast(query: query, results: &results)
    }
}

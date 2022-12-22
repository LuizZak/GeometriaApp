public struct AnyRaytracingElement {
    public var element: RaytracingElement
    
    public init<T: RaytracingElement>(_ element: T) {
        self.element = element
    }
    
    public init?(_ anyElement: AnyElement) {
        guard let element = anyElement.element as? RaytracingElement else {
            return nil
        }

        self.element = element
    }
}

extension AnyRaytracingElement: Element {
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

extension AnyRaytracingElement: RaytracingElement {
    public func raycast(query: RayQuery) -> RayQuery {
        element.raycast(query: query)
    }
    public func raycast(query: RayQuery, results: inout [RayHit]) {
        element.raycast(query: query, results: &results)
    }
    public func fullyContainsRay(query: RayQuery) -> Bool {
        element.fullyContainsRay(query: query)
    }
}

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

    @inlinable
    public func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        element.accept(visitor)
    }
}

extension AnyRaytracingElement: RaytracingElement {
    @inlinable
    public func raycast(query: RayQuery) -> RayQuery {
        element.raycast(query: query)
    }
    
    @inlinable
    public func raycast(query: RayQuery, results: inout SortedRayHits) {
        element.raycast(query: query, results: &results)
    }

    @inlinable
    public func fullyContainsRay(query: RayQuery) -> Bool {
        element.fullyContainsRay(query: query)
    }
}

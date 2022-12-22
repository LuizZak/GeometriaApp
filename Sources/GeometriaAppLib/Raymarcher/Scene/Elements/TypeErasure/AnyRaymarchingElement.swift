public struct AnyRaymarchingElement {
    public var element: RaymarchingElement
    
    public init<T: RaymarchingElement>(_ element: T) {
        self.element = element
    }
    
    public init?(_ anyElement: AnyElement) {
        guard let element = anyElement.element as? RaymarchingElement else {
            return nil
        }

        self.element = element
    }
}

extension AnyRaymarchingElement: Element {
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

extension AnyRaymarchingElement: RaymarchingElement {
    public func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        element.signedDistance(to: point, current: current)
    }

    public func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        element.accept(visitor)
    }
}

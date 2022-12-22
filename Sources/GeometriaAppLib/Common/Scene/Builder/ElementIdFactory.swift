public struct ElementIdFactory {
    private var _nextId: Element.Id = 0
    
    public mutating func makeId() -> Element.Id {
        defer { _nextId += 1 }
        return _nextId
    }
}

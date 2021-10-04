struct ElementIdFactory {
    private var _nextId: Int = 0
    
    mutating func makeId() -> Int {
        defer { _nextId += 1 }
        return _nextId
    }
}

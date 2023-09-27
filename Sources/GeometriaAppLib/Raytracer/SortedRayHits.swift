/// A list of `RayHit` values that are automatically sorted by distance on insertion.
public struct SortedRayHits {
    @usableFromInline
    internal var hits: [RayHit] = []

    @inlinable
    public init() {

    }

    @inlinable
    public init(hits: [RayHit]) {
        self.hits = hits
    }

    @inlinable
    public mutating func insert(_ hit: RayHit) {
        let index = hits.partitioningIndex {
            $0.distanceSquared > hit.distanceSquared
        }

        self.hits.insert(hit, at: index)
    }

    // TODO: Add specialized overload for faster insertion of `SortedRayHits` sequences.
    @inlinable
    public mutating func insert<S: Sequence<RayHit>>(contentsOf sequence: S) {
        for el in sequence {
            insert(el)
        }
    }

    @inlinable
    internal mutating func sort() {
        self.hits.sort(by: {
            $0.distanceSquared < $1.distanceSquared
        })
    }
}

extension SortedRayHits: ExpressibleByArrayLiteral {
    @inlinable
    public init(arrayLiteral: RayHit...) {
        self.hits = arrayLiteral

        sort()
    }
}

extension SortedRayHits: Sequence {
    @inlinable
    public func makeIterator() -> [RayHit].Iterator {
        return hits.makeIterator()
    }
}

extension SortedRayHits: Collection {
    @inlinable
    public var startIndex: Int { hits.startIndex }
    @inlinable
    public var endIndex: Int { hits.endIndex }

    @inlinable
    public subscript(position: Int) -> RayHit {
        hits[position]
    }

    @inlinable
    public func index(after i: Int) -> Int {
        hits.index(after: i)
    }
}

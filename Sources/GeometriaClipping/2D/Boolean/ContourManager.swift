import Geometria
import MiniDigraph

/// Manages inclusions/merging of contour objects.
@usableFromInline
class ContourManager {
    @usableFromInline
    internal typealias ContourContainmentGraph = CachingDirectedGraph<Int, DirectedGraph<Int>.Edge>

    @usableFromInline
    typealias Vector = Vector2D
    @usableFromInline
    typealias Contour = Parametric2Contour<Vector>
    @usableFromInline
    typealias Simplex = Parametric2GeometrySimplex<Vector>
    @usableFromInline
    typealias Period = Vector.Scalar

    @usableFromInline
    internal var inputContours: [ContourInfo]

    @usableFromInline
    init() {
        inputContours = []
    }

    @inlinable
    func allContours() -> [Contour] {
        return finishContours()
    }

    @usableFromInline
    func append(_ contour: Contour, isReference: Bool = false) {
        inputContours.append(
            .init(contour: contour, isReference: isReference)
        )
    }

    @usableFromInline
    func beginContour() -> ContourBuilder {
        return ContourBuilder(manager: self)
    }

    /// Applies winding rules with the current reference and non-reference contours,
    /// removing hole contours, and removing all reference contours in the process.
    @inlinable
    func coverHoles() {
        var graph = contourGraph()
        let initialNodes = graph.nodes

        graph.pruneByWinding(
            windingNumber: { windingNumber(of: $0) },
            winding: { winding(of: $0) }
        )

        let difference = initialNodes
            .subtracting(graph.nodes)
            .sorted(by: { $0 > $1 })
        for index in difference {
            inputContours.remove(at: index)
        }

        inputContours.removeAll(where: { $0.isReference })
    }

    /// Creates a graph of the containment dependencies: Contours that contain
    /// others have an edge added such that: outer -> inner
    @inlinable
    func contourGraph() -> ContourContainmentGraph {
        let range = 0..<inputContours.count

        var graph = ContourContainmentGraph()
        graph.addNodes(0..<inputContours.count)

        for lhsIndex in range {
            let lhs = inputContours[lhsIndex].contour

            for rhsIndex in range.dropFirst(lhsIndex + 1) {
                let rhs = inputContours[rhsIndex].contour

                if isContained(lhs, within: rhs) {
                    graph.addEdge(from: rhsIndex, to: lhsIndex)
                } else if isContained(rhs, within: lhs) {
                    graph.addEdge(from: lhsIndex, to: rhsIndex)
                }
            }
        }

        return graph
    }

    @inlinable
    func finishContours() -> [Contour] {
        var graph = self.contourGraph()

        graph.pruneByWinding(
            windingNumber: windingNumber(of:),
            winding: winding(of:)
        )

        guard let sorted = graph.topologicalSorted(breakTiesWith: { $0 < $1 }) else {
            fatalError("Found cyclic contour containment dependency?")
        }

        return sorted.filter({ !inputContours[$0].isReference }).map(contourForNode)
    }

    @inlinable
    func contourForNode(_ node: ContourContainmentGraph.Node) -> Contour {
        inputContours[node].contour
    }

    @inlinable
    func windingNumber(of contour: Contour) -> Int {
        switch contour.winding {
        case .clockwise: return 1
        case .counterClockwise: return -1
        }
    }

    @inlinable
    func winding(of node: ContourContainmentGraph.Node) -> Contour.Winding {
        contourForNode(node).winding
    }

    @inlinable
    func windingNumber(of node: ContourContainmentGraph.Node) -> Int {
        windingNumber(of: contourForNode(node))
    }

    @inlinable
    func isContained(_ lhs: Contour, within rhs: Contour) -> Bool {
        guard rhs.bounds.contains(lhs.bounds) else {
            return false
        }

        func probe(_ period: Contour.Period) -> Bool {
            rhs.contains(lhs.compute(at: period))
        }

        return probe(lhs.startPeriod)
            || probe(lhs.endPeriod)
            || probe(lhs.normalizedCenter(lhs.startPeriod, lhs.endPeriod))
    }

    @usableFromInline
    struct ContourInfo {
        @usableFromInline
        var contour: Contour
        @usableFromInline
        var isReference: Bool
        @inlinable
        var isShell: Bool { contour.winding == .clockwise }
        @inlinable
        var isHole: Bool { contour.winding == .counterClockwise }
    }

    @usableFromInline
    class ContourBuilder {
        private var hasEnded: Bool = false
        private let manager: ContourManager
        private var simplexes: [Simplex]

        init(manager: ContourManager) {
            self.manager = manager
            self.simplexes = []
        }

        @usableFromInline
        func append<S: Sequence>(contentsOf simplexes: S) where S.Element == Simplex {
            assert(!hasEnded, "!hasEnded: Attempted to append simplexes to finished contour")

            self.simplexes.append(contentsOf: simplexes)
        }

        @usableFromInline
        func append(_ simplex: Simplex) {
            assert(!hasEnded, "!hasEnded: Attempted to append simplex to finished contour")

            simplexes.append(simplex)
        }

        @usableFromInline
        func endContour(startPeriod: Period, endPeriod: Period) {
            assert(!hasEnded, "!hasEnded: Attempted to end already finished contour")

            hasEnded = true

            let contour = self.contour(startPeriod: startPeriod, endPeriod: endPeriod)
            manager.append(contour)
        }

        private func contour(startPeriod: Period, endPeriod: Period) -> Contour {
            Contour(
                normalizing: simplexes,
                startPeriod: startPeriod,
                endPeriod: endPeriod
            )
        }
    }
}

private extension DirectedGraphType {
    func entryNodes() -> Set<Node> {
        nodes.filter { indegree(of: $0) == 0 }
    }
}

internal extension CachingDirectedGraph where Node == Int, Edge: SimpleDirectedGraphEdge {
    /// Traverses the graph, ensuring that the nested winding number of each
    /// contour matches the contour's winding.
    @inlinable
    mutating func pruneByWinding<Vector>(
        windingNumber: (Node) -> Int,
        winding: (Node) -> Parametric2Contour<Vector>.Winding
    ) {
        func _removeNode(_ node: Node) {
            let nodesFrom = nodesConnected(from: node)
            let nodesTo = nodesConnected(towards: node)

            removeNode(node)

            for nodeFrom in nodesFrom {
                for nodeTo in nodesTo {
                    addEdge(from: nodeTo, to: nodeFrom)
                }
            }
        }

        var nodesToRemove: [Node] = []
        for node in nodes {
            let totalWinding = totalWindingNumber(
                of: node,
                windingNumber: windingNumber
            )
            let shouldRemove: Bool

            switch winding(node) {
            case .clockwise:
                // 'Shell' contours require a winding of exactly 1
                shouldRemove = totalWinding != 1

            case .counterClockwise:
                // 'Hole' contours require a winding of exactly 0
                shouldRemove = totalWinding != 0
            }

            if shouldRemove {
                nodesToRemove.append(node)
            }
        }

        for node in nodesToRemove {
            _removeNode(node)
        }
    }

    @inlinable
    func totalWindingNumber(
        of node: Node,
        windingNumber: (Node) -> Int
    ) -> Int {
        var totalWinding = 0

        var queue = [node]
        var visited: Set<Node> = []
        while !queue.isEmpty {
            let next = queue.removeFirst()

            if visited.insert(next).inserted {
                totalWinding += windingNumber(next)
                queue.append(contentsOf: nodesConnected(towards: next))
            }
        }

        return totalWinding
    }
}

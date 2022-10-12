#if canImport(Geometria)
import Geometria
#endif

/// From a structured set of bounded geometry laid out in space, creates subdivided
/// AABBs to quickly query geometry that is neighboring a point or line.
class OctTree<T: BoundableType> where T.Vector == RVector3D {
    typealias Bounds = AABB3D

    /// The list of geometry that is being bounded.
    private var geometryList: [T]

    private var root: Subdivision

    /// Initializes an empty oct tree object.
    convenience init() {
        self.init([], maxSubdivisions: 0, maxElementsPerOctBeforeSplit: 0)
    }

    /// Initializes an oct tree that contains the given geometry, with initial
    /// parameters to generate the oct tree division that can fit the geometry.
    ///
    /// - Parameters:
    ///   - geometry: The list of geometries to pack in the oct tree.
    ///   - maxSubdivisions: The maximum number of subdivisions allowed in the
    /// oct tree. Takes precedence over `maxElementsPerOctBeforeSplit` when
    /// splitting the oct tree.
    ///   - maxElementsPerOctBeforeSplit: The maximum number of elements per oct
    /// tree subdivision before an attempt to subdivide it further is done.
    init(_ geometryList: [T], maxSubdivisions: Int, maxElementsPerOctBeforeSplit: Int) {
        self.geometryList = geometryList

        // Calculate minimum bounds
        let bounds = geometryList.map(\.bounds)
        let totalBounds = Bounds(of: bounds)
        let indices = Array(geometryList.indices)

        self.root =
            .leaf(
                state: .init(
                    bounds: totalBounds,
                    indices: indices,
                    maxDepth: 0,
                    totalIndicesCount: indices.count,
                    isEmpty: indices.isEmpty
                )
            ).pushingGeometryDownRecursive(
                bounds,
                maxSubdivisions: maxSubdivisions,
                maxElementsPerOctBeforeSplit: maxElementsPerOctBeforeSplit
            )
    }

    /// Returns all of the geometry that are contained within this oct tree whose
    /// bounds contain a given point.
    func queryPoint(_ point: RVector3D) -> [T] {
        var result: [T] = []

        root.queryPointRecursive(point) { index in
            let geometry = geometryList[index]

            if geometry.bounds.contains(point) {
                result.append(geometry)
            }
        }

        return result
    }

    /// Returns all of the geometry that are contained within this oct tree whose
    /// bounds intersect a given line.
    func queryLine<Line: LineFloatingPoint>(
        _ line: Line
    ) -> [T] where Line.Vector == RVector3D {

        var result: [T] = []

        root.queryLineRecursive(line) { index in
            let geometry = geometryList[index]

            if geometry.bounds.intersects(line: line) {
                result.append(geometry)
            }
        }

        return result
    }

    private struct SubdivisionState {
        /// Initializes an empty subdivision state.
        static func empty(bounds: Bounds) -> Self {
            .init(
                bounds: .zero,
                indices: [],
                maxDepth: 0,
                totalIndicesCount: 0,
                isEmpty: true
            )
        }

        /// Defines the boundaries of a subdivision.
        var bounds: Bounds

        /// Indices in the root geometry array from the owning `OctTree` that 
        /// represent the geometry that is allocated at this depth.
        ///
        /// The same index is not present in sub-divisions of this tree.
        var indices: [Int]
        
        /// The maximal depth of this particular subdivision tree, including all
        /// nested subdivisions.
        var maxDepth: Int

        /// Returns the total number of indices within this particular subdivision
        /// tree, including all nested subdivisions.
        var totalIndicesCount: Int

        /// Is `true` if the subdivision associated with this state has no indices
        /// contained within any level deeper than that subdivision, including
        /// itself.
        var isEmpty: Bool

        func withMaxDepthIncreased(by depth: Int) -> Self {
            var copy = self
            copy.maxDepth += depth
            return self
        }

        func addingIndex(_ index: Int) -> Self {
            var copy = self
            
            if !copy.indices.contains(index) {
                copy.indices.append(index)
                copy.totalIndicesCount += 1
                copy.isEmpty = false
            }

            return copy
        }

        func addingIndices<S: Sequence>(_ indices: S) -> Self where S.Element == Int {
            indices.reduce(self, { $0.addingIndex($1) })
        }

        func removingIndex(_ index: Int) -> Self {
            var copy = self
            
            if copy.indices.contains(index) {
                copy.indices.removeAll { $0 == index }
                copy.totalIndicesCount -= 1
                copy.isEmpty = copy.indices.isEmpty
            }

            return copy
        }

        func removingIndices<S: Sequence>(_ indices: S) -> Self where S.Element == Int {
            indices.reduce(self, { $0.removingIndex($1) })
        }
    }

    private enum Subdivision {
        /// Creates and returns an empty leaf subdivision with the given boundaries.
        static func empty(bounds: Bounds) -> Self {
            .empty(state: .empty(bounds: bounds))
        }
        
        /// Creates and returns an empty leaf subdivision with the given state.
        static func empty(state: SubdivisionState) -> Self {
            .leaf(state: state)
        }

        case leaf(
            state: SubdivisionState
        )

        indirect case subdivision(
            state: SubdivisionState,
            octant1: Self,
            octant2: Self,
            octant3: Self,
            octant4: Self,
            octant5: Self,
            octant6: Self,
            octant7: Self,
            octant8: Self
        )

        /// Gets the maximum depth within this subdivision object.
        ///
        /// Is 0 for `Self.leaf` cases, and + 1 of the greatest subdivision depth
        /// of nested `Self.subdivision` cases.
        var maxDepth: Int {
            state.maxDepth
        }

        /// Gets the bounds that this subdivision occupies in space.
        var bounds: Bounds {
            state.bounds
        }

        /// Gets the indices on this subdivision, not including the deeper
        /// subdivisions.
        var indices: [Int] {
            state.indices
        }

        /// Gets the common state for this subdivision object.
        var state: SubdivisionState {
            switch self {
            case .leaf(let state),
                .subdivision(let state, _, _, _, _, _, _, _, _):

                return state
            }
        }

        /// Returns `true` if this subdivision object contains nested subdivisions.
        var hasSubdivisions: Bool {
            switch self {
            case .leaf:
                return false
            
            case .subdivision:
                return true
            }
        }

        /// Returns all the indices that are contained within this subdivision
        /// tree, and all subsequent depths on this tree recursively whose bounds
        /// contain the point.
        func queryPointRecursive(_ point: RVector3D, _ out: inout [Int]) {
            if !bounds.contains(point) {
                return
            }

            out.append(contentsOf: indices)

            applyToSubdivisions { octant in
                octant.queryPointRecursive(point, &out)
            }
        }

        /// Executes a closure for each index that is contained within this
        /// subdivision tree, and all subsequent depths on this tree recursively
        /// whose bounds contain the point.
        func queryPointRecursive(_ point: RVector3D, closure: (Int) -> Void) {
            if !bounds.contains(point) {
                return
            }

            indices.forEach(closure)

            applyToSubdivisions { octant in
                octant.queryPointRecursive(point, closure: closure)
            }
        }

        /// Returns all the indices that are contained within this subdivision
        /// tree, and all subsequent depths on this tree recursively whose bounds
        /// intersect the given line.
        func queryLineRecursive<Line: LineFloatingPoint>(
            _ line: Line,
            _ out: inout [Int]
        ) where Line.Vector == RVector3D {

            if !bounds.intersects(line: line) {
                return
            }

            out.append(contentsOf: indices)

            applyToSubdivisions { octant in
                octant.queryLineRecursive(line, &out)
            }
        }

        /// Executes a closure for each index that is contained within this
        /// subdivision tree, and all subsequent depths on this tree recursively
        /// whose bounds intersect the given line.
        func queryLineRecursive<Line: LineFloatingPoint>(
            _ line: Line,
            closure: (Int) -> Void
        ) where Line.Vector == RVector3D {

            if !bounds.intersects(line: line) {
                return
            }

            indices.forEach(closure)

            applyToSubdivisions { octant in
                octant.queryLineRecursive(line, closure: closure)
            }
        }

        /// Appends the indices of this subdivision depth, and all subsequent
        /// depths on this tree recursively.
        func totalIndicesInTree(_ out: inout [Int]) {
            out.append(contentsOf: indices)

            applyToSubdivisions { octant in
                octant.totalIndicesInTree(&out)
            }
        }

        /// Requests that this subdivision object be subdivided, in case it is
        /// not already.
        ///
        /// The bounds of this subdivision will be computed as the eight-way split
        /// of the bounds of this subdivision object.
        ///
        /// Indices within this state are not changed.
        ///
        /// Returns `self`, if this object is already subdivided.
        func subdivided() -> Self {
            switch self {
            case .leaf(let state):
                let octants = state.bounds.octants()
                
                return .subdivision(
                    state: state.withMaxDepthIncreased(by: 1),
                    octant1: .empty(bounds: octants.0),
                    octant2: .empty(bounds: octants.1),
                    octant3: .empty(bounds: octants.2),
                    octant4: .empty(bounds: octants.3),
                    octant5: .empty(bounds: octants.4),
                    octant6: .empty(bounds: octants.5),
                    octant7: .empty(bounds: octants.6),
                    octant8: .empty(bounds: octants.7)
                )

            case .subdivision:
                return self
            }
        }

        /// Recursively checks that geometry indices referenced by this subdivision
        /// object, whose real values are contained in the passed `array`, can
        /// be fitted into a lower subdivision level, and performs subdivisions
        /// according to the subdivision limits specified, if necessary.
        ///
        /// The array of bounds should be the computed bounds of every object
        /// contained within the parent `OctTree`.
        ///
        /// The resulting subdivision object contains the same indices and the
        /// same depth, but objects are contained within the deepest level that
        /// can fully contain their bounds.
        ///
        /// - Parameters:
        ///   - maxSubdivisions: The maximum number of subdivisions allowed in the
        /// oct tree. Takes precedence over `maxElementsPerOctBeforeSplit` when
        /// splitting the oct tree.
        ///   - maxElementsPerOctBeforeSplit: The maximum number of elements per oct
        /// tree subdivision before an attempt to subdivide it further is done.
        func pushingGeometryDownRecursive(
            _ geometryBounds: [Bounds],
            maxSubdivisions: Int,
            maxElementsPerOctBeforeSplit: Int
        ) -> Self {

            var indices = Set(self.indices)
            
            var copy = self

            copy._pushGeometryDownRecursive(
                geometryBounds,
                indices: &indices,
                maxSubdivisions: maxSubdivisions,
                maxElementsPerOctBeforeSplit: maxElementsPerOctBeforeSplit
            )

            // Re-accept any remaining index that was not accepted by deeper
            // subtrees.
            copy.mutateState { state in
                state = state.addingIndices(indices)
            }

            return copy
        }

        private mutating func _pushGeometryDownRecursive(
            _ geometryBounds: [Bounds],
            indices: inout Set<Int>,
            maxSubdivisions: Int,
            maxElementsPerOctBeforeSplit: Int
        ) {
            
            // Accept all geometries that can be contained within this subdivision
            // first
            mutateState { state in
                for index in indices where state.bounds.contains(geometryBounds[index]) {
                    state = state.addingIndex(index)
                    indices.remove(index)
                }
            }

            if !hasSubdivisions {
                if self.indices.count > maxElementsPerOctBeforeSplit && maxSubdivisions > 0 {
                    self = subdivided()
                } else {
                    return
                }
            }

            var newIndices = Set(self.indices)

            // Push down the indices contained within this tree subdivision deeper
            // down
            mutateSubdivisions { octant in
                octant._pushGeometryDownRecursive(
                    geometryBounds,
                    indices: &newIndices,
                    maxSubdivisions: maxSubdivisions - 1,
                    maxElementsPerOctBeforeSplit: maxElementsPerOctBeforeSplit
                )
            }

            // Remove all the indices that where accepted by deeper subdivisions.
            mutateState { state in
                state = state.removingIndices(
                    Set(state.indices).subtracting(newIndices)
                )
            }
        }

        /// Applies a given closure to the first depth of subdivisions within
        /// this subdivision object, non-recursively.
        ///
        /// In case this object is a `.leaf`, nothing is done.
        func applyToSubdivisions(_ closure: (Self) -> Void) {
            switch self {
            case .leaf:
                break
            case .subdivision(
                _,
                let octant1,
                let octant2,
                let octant3,
                let octant4,
                let octant5,
                let octant6,
                let octant7,
                let octant8
            ):

                closure(octant1)
                closure(octant2)
                closure(octant3)
                closure(octant4)
                closure(octant5)
                closure(octant6)
                closure(octant7)
                closure(octant8)
            }
        }

        /// Applies a given closure to the first depth of subdivisions within
        /// this subdivision object, non-recursively, returning the result of
        /// mutating each individual subdivision with a given closure.
        ///
        /// In case this object is a `.leaf`, nothing is done.
        private mutating func mutateSubdivisions(_ closure: (inout Self) -> Void) {
            switch self {
            case .leaf:
                break
            case .subdivision(
                let state,
                var octant1,
                var octant2,
                var octant3,
                var octant4,
                var octant5,
                var octant6,
                var octant7,
                var octant8
            ):

                closure(&octant1)
                closure(&octant2)
                closure(&octant3)
                closure(&octant4)
                closure(&octant5)
                closure(&octant6)
                closure(&octant7)
                closure(&octant8)

                self = .subdivision(
                    state: state,
                    octant1: octant1,
                    octant2: octant2,
                    octant3: octant3,
                    octant4: octant4,
                    octant5: octant5,
                    octant6: octant6,
                    octant7: octant7,
                    octant8: octant8
                )
            }
        }

        /// Performs an in-place mutation of this subdivision object, with the
        /// state modified by a given closure.
        mutating func mutateState(_ mutator: (inout SubdivisionState) -> Void) {
            self = self.mutatingState(mutator)
        }

        /// Returns a copy of this subdivision object, with the state modified
        /// by a given closure.
        func mutatingState(_ mutator: (inout SubdivisionState) -> Void) -> Self {
            switch self {
            case .leaf(var state):
                mutator(&state)
                return .leaf(state: state)
            
            case .subdivision(
                var state,
                let octant1,
                let octant2,
                let octant3,
                let octant4,
                let octant5,
                let octant6,
                let octant7,
                let octant8
            ):

                mutator(&state)

                return .subdivision(
                    state: state,
                    octant1: octant1,
                    octant2: octant2,
                    octant3: octant3,
                    octant4: octant4,
                    octant5: octant5,
                    octant6: octant6,
                    octant7: octant7,
                    octant8: octant8
                )
            }
        }
    }
}

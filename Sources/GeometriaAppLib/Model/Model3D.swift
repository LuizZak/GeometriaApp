/// Packs information for displaying a 3D model as a vertex/index list.
struct Model3D {
    /// An array where each index represents the number of vertices for a face.
    var faceIndex: [Int]

    /// The array of vertices in 3D space.
    var vertices: [RVector3D]

    /// An array of indices that tesselate triangles into the `vertices` array.
    var indices: [Int]
}

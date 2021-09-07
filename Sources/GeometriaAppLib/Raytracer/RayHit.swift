import Geometria

struct RayHit {
    var point: Vector3D
    var normal: Vector3D
    var intersection: ConvexLineIntersection<Vector3D>
    var sceneGeometry: SceneGeometry
}

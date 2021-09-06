import Geometria

struct RayHit {
    var point: Vector3D
    var normal: Vector3D
    var geometry: GeometricType
    var sceneGeometry: SceneGeometry
}

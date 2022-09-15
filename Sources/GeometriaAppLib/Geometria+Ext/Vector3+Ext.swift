#if canImport(Geometria)

import Geometria

extension Vector3 where Self: Vector3Real {
    public func rotated(by matrix: RotationMatrix3<Scalar>, around center: Self) -> Self {
        matrix.transformPoint(self - center) + center
    }
}

public extension Sequence where Element: Vector3Real {
    func transformed(by matrix: Matrix3x3<Element.Scalar>) -> [Element] {
        map {
            matrix.transformPoint($0)
        }
    }
}

#else

extension Vector3 {
    public func rotated(by matrix: RotationMatrix3D, around center: Self) -> Self {
        matrix.transformPoint(self - center) + center
    }
}

public extension Sequence where Element: Vector3Real {
    func transformed(by matrix: Matrix3x3D) -> [Element] {
        map {
            matrix.transformPoint($0)
        }
    }
}

#endif

#if canImport(Geometria)
import Geometria
#endif

typealias RepeatTranslateRaymarchingElement<T: RaymarchingElement> = RepeatTranslateElement<T>

extension RepeatTranslateRaymarchingElement: RaymarchingElement {
    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        var index = 0
        while index < count {
            defer { index += 1 }
            
            let translated = point - translation * Double(index)
            let next = element.signedDistance(to: translated, current: current)

            // If a translation brought the geometry farther away from the point, 
            // the remaining translations will be farther away as well.
            if index > 0 && next.distance > current.distance {
                return current
            }

            current = next
        }
        
        return current
    }

    func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

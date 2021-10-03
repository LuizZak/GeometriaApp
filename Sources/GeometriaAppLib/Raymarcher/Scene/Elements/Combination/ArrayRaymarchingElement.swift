struct ArrayRaymarchingElement: RaymarchingElement {
    var elements: [RaymarchingElement]

    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        for el in elements {
            current = el.signedDistance(to: point, current: current)
        }
        
        return current
    }
}

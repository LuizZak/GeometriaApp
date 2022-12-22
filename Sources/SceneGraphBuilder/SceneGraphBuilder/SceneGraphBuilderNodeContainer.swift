import ImagineUI

/// A view that acts as an infinitely-bounded view for node containment,
/// with dedicated.
class SceneGraphBuilderNodeContainer: View {
    var translation: UIVector = .zero {
        willSet {
            invalidate()
        }
        didSet {
            invalidate()
        }
    }

    var zoom: Double {
        get {
            min(scale.x, scale.y)
        }
        set {
            scale = .init(repeating: newValue)
        }
    }

    override var transform: UIMatrix {
        UIMatrix.transformation(
            xScale: scale.x,
            yScale: scale.y,
            angle: rotation,
            xOffset: (location.x + translation.x),
            yOffset: (location.y + translation.y)
        )
    }

    override init() {
        super.init()

        clipToBounds = false
    }

    override func contains(point: UIVector, inflatingArea: UIVector = .zero) -> Bool {
        return true
    }

    override func intersects(area: UIRectangle, inflatingArea: UIVector = .zero) -> Bool {
        return true
    }

    override func boundsForRedraw() -> UIRectangle {
        UIRectangle.union(subviews.map { view in
            convert(bounds: view.boundsForRedraw(), from: view)
        })
    }
}

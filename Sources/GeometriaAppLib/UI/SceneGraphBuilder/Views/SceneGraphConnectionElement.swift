import ImagineUI

/// Encapsulates information about rendering a connection used as visual
/// indication of the connection between two elements on a scene graph view.
class SceneGraphConnectionElement {
    var startAnchor: AnchorElement?
    var endAnchor: AnchorElement?

    /// If non-nil, indicates a visual `UIBezier` is being used to visually
    /// illustrate the connection.
    var bezier: UIBezier?

    init(startAnchor: AnchorElement? = nil, endAnchor: AnchorElement? = nil) {
        self.startAnchor = startAnchor
        self.endAnchor = endAnchor
    }

    /// Returns `true` if this visual connection element references a given view
    /// object either as its start or end anchors.
    func isAssociatedWith(_ view: View) -> Bool {
        startAnchor?.associatedView == view || endAnchor?.associatedView == view
    }

    /// Reference to an element that anchors one of the ends of this connection
    /// view.
    enum AnchorElement {
        /// Anchor is the input of a graph node view.
        case input(SceneGraphNodeView, index: Int)

        /// Anchor is the output of a graph node view.
        case output(SceneGraphNodeView, index: Int)

        /// Anchors to a view object in another hierarchy, with a given offset
        /// that is relative to view itself.
        case view(View, localOffset: UIPoint)

        /// Anchors to a global location point.
        case globalLocation(UIPoint)

        fileprivate var associatedView: View? {
            switch self {
            case .input(let view, _), .output(let view, _):
                return view
            case .view(let view, _):
                return view
            case .globalLocation:
                return nil
            }
        }
    }
}

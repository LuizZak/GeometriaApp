import Foundation
import SwiftBlend2D
import ImagineUI
import Text
import Blend2DRenderer
import GeometriaAppLib

open class RaytracerGraphApp: RaytracerUI {
    public override init(size: UIIntSize) {
        super.init(size: size)

        createUI()
    }
    
    func createUI() {
        ControlView.globallyCacheAsBitmap = false
        Label.globallyCacheAsBitmap = false

        let sceneGraph = SceneGraphBuilderComponent()
        addComponent(sceneGraph)
    }
}

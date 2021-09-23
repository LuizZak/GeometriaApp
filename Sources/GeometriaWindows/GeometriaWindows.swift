import GeometriaAppLib
import SwiftWin32
import Foundation

private class WinGeometria {
  private var window: Window

  public init(windowScene: WindowScene) {
    self.window = Window(windowScene: windowScene)

    self.window.rootViewController = ViewController()
    self.window.rootViewController?.title = "WinGeometria"
    
    self.window.makeKeyAndVisible()
  }
}

public final class GeometriaAppDelegate: ApplicationDelegate, SceneDelegate {
  private var geometria: WinGeometria?

  public init() {
      
  }

  public func scene(_ scene: Scene, 
                    willConnectTo session: SceneSession,
                    options: Scene.ConnectionOptions) {
    
    guard let windowScene = scene as? WindowScene else { return }

    windowScene.sizeRestrictions?.minimumSize = Size(width: 400, height: 300)
    windowScene.sizeRestrictions?.maximumSize = Size(width: 2560, height: 1440)

    self.geometria = WinGeometria(windowScene: windowScene)
  }
}

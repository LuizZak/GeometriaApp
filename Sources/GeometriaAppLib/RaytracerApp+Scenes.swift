import SwiftBlend2D

extension RaytracerApp {
    func createScenes() -> [SceneEntry] {
        var result: [SceneEntry] = []
        result.append(contentsOf: createRaytracingScenes())
        result.append(contentsOf: createRaymarchingScenes())
        return result
    }

    func createRaytracingScenes() -> [SceneEntry] {
        var result: [SceneEntry] = []

        func add<Scene: RaytracingSceneType>(_ name: String, _ scene: Scene) {
            let entry = createRaytracing(name: name, scene: scene)
            result.append(entry)
        }

        add("Raytracing Demo 1", RaytracingDemoScene1.makeScene())
        add("Raytracing Demo 2", RaytracingDemoScene2.makeScene())
        add("Raytracing Demo 3", RaytracingDemoScene3.makeScene())
        add("Raytracing Demo 4", RaytracingDemoScene4.makeScene())
        add("Raytracing Half-Subtract", RaytracingHalfSubtract.makeScene())
        add("Raytracing Hyperplane Polyhedron", RaytracingHyperplanePolyhedronScene.makeScene())

        return result
    }

    func createRaymarchingScenes() -> [SceneEntry] {
        var result: [SceneEntry] = []

        func add<Scene: RaymarchingSceneType>(_ name: String, _ scene: Scene) {
            let entry = createRaymarching(name: name, scene: scene)
            result.append(entry)
        }

        add("Raymarching Demo 1", RaymarchingDemoScene1.makeScene())
        add("Raymarching Demo 2", RaymarchingDemoScene2.makeScene())
        add("Raymarching Demo 3", RaymarchingDemoScene3.makeScene())
        add("Raymarching Demo 4", RaymarchingDemoScene4.makeScene())
        add("Raymarching Demo 5", RaymarchingDemoScene5.makeScene())
        add("Raymarching Hyperplane Polyhedron", RaymarchingHyperplanePolyhedronScene.makeScene())

        return result
    }
}

private func createRaytracing<Scene: RaytracingSceneType>(name: String, scene: Scene) -> RaytracerApp.SceneEntry {
    return .init(name: name) { (width, height, threadCount) in
        let image = BLImage(
            width: width,
            height: height,
            format: .prgb32
        )

        let viewportSize = image.size.asViewportSize

        let buffer = Blend2DBufferWriter(image: image)

        let batcher = TiledBatcher(
            splitting: viewportSize,
            estimatedThreadCount: threadCount * 2,
            shuffleOrder: true
        )

        // TODO: Derive camera configuration from the demo scene builders.

        let camera = Camera(
            viewportSize: viewportSize,
            viewportCenter: .init(x: 0.0, y: 0, z: 90.0)
        )

        let renderer = Raytracer(
            scene: scene,
            camera: camera
        )

        renderer.setupViewportSize(viewportSize)

        let rendererCoordinator = RendererCoordinator(
            renderer: renderer,
            viewportSize: viewportSize,
            buffer: buffer,
            threadCount: threadCount,
            batcher: batcher
        )

        return (buffer, renderer, rendererCoordinator)
    }
}

private func createRaymarching<Scene: RaymarchingSceneType>(name: String, scene: Scene) -> RaytracerApp.SceneEntry {
    return .init(name: name) { (width, height, threadCount) in
        let image = BLImage(
            width: width,
            height: height,
            format: .prgb32
        )

        let viewportSize = image.size.asViewportSize

        let buffer = Blend2DBufferWriter(image: image)

        let batcher = TiledBatcher(
            splitting: viewportSize,
            estimatedThreadCount: threadCount * 2,
            shuffleOrder: true
        )

        // TODO: Derive camera configuration from the demo scene builders.

        let camera = Camera(
            viewportSize: viewportSize,
            viewportCenter: .init(x: 0.0, y: 0, z: 90.0)
        )

        let renderer = Raymarcher(
            scene: scene,
            camera: camera
        )

        renderer.setupViewportSize(viewportSize)

        let rendererCoordinator = RendererCoordinator(
            renderer: renderer,
            viewportSize: viewportSize,
            buffer: buffer,
            threadCount: threadCount,
            batcher: batcher
        )

        return (buffer, renderer, rendererCoordinator)
    }
}

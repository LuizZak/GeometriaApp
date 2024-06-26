import Foundation
import ImagineUI
import Blend2DRenderer

class SceneListComponent: RaytracerUIComponent {
    private var _mouseLocation: UIPoint = .zero
    private let treeView = TreeView()
    private var sceneDataSource: SceneDataSource

    let sidePanel: SidePanel

    weak var delegate: RaytracerUIComponentDelegate?

    /// Delegate for interactions with the tree view.
    weak var treeComponentDelegate: SceneListComponentDelegate?

    init(width: Double, scenes: [SceneEntry]) {
        self.sidePanel = SidePanel(pinSide: .right, length: width)
        self.sceneDataSource = SceneDataSource(scenes: scenes)

        setupTreeViewEvents()

        treeView.dataSource = sceneDataSource
    }

    func setup(container: View) {
        container.addSubview(sidePanel)
        sidePanel.addSubview(treeView)

        treeView.layout.makeConstraints { make in
            make.edges == sidePanel.contentBounds
        }
    }

    func rendererCoordinatorChanged(_ coordinator: RendererCoordinator?) {

    }

    func rendererChanged<T>(anyRenderer: T) where T : RendererType {

    }

    /// Artificially triggers a treeview selection event, selecting the item
    /// in the interface and triggering the item selection event.
    func selectEntryIndex(_ index: Int) {
        treeView.setSelection([
            .init(parent: .root, index: index),
        ])
    }

    private func setupTreeViewEvents() {
        treeView.didChangeSelection.addListener(weakOwner: self) { [weak self] (sender, args) in
            self?.onItemSelectionChanged(args.newValue)
        }
    }

    private func onItemSelectionChanged(_ selection: Set<TreeView.ItemIndex>) {
        guard let treeComponentDelegate = treeComponentDelegate else { return }

        guard
            let first = selection.first,
            let scene = sceneDataSource.itemAt(first)
        else {
            return
        }

        treeComponentDelegate.sceneListComponent(
            self,
            didChangeSelection: scene
        )
    }

    struct SceneEntry {
        var name: String

        static func from(_ entry: RaytracerApp.SceneEntry) -> Self {
            .init(name: entry.name)
        }
    }

    private class SceneDataSource: TreeViewDataSource {
        typealias ItemType = SceneEntry

        var scenes: [SceneEntry]

        init(scenes: [SceneEntry]) {
            self.scenes = scenes
        }

        func itemAt(_ itemIndex: TreeView.ItemIndex) -> ItemType? {
            return scenes[itemIndex.index]
        }

        func itemAt(hierarchyIndex: TreeView.HierarchyIndex) -> ItemType? {
            guard let index = hierarchyIndex.indices.last else {
                return nil
            }

            return scenes[index]
        }

        func hasSubItems(at index: TreeView.ItemIndex) -> Bool {
            false
        }

        func numberOfItems(at hierarchyIndex: TreeView.HierarchyIndex) -> Int {
            if hierarchyIndex.isRoot {
                return scenes.count
            }

            return 0
        }

        func titleForItem(at index: TreeView.ItemIndex) -> AttributedText {
            guard let item = itemAt(hierarchyIndex: index.asHierarchyIndex) else {
                return "<<invalid item index \(index)>>"
            }

            return AttributedText(item.name)
        }

        func iconForItem(at index: TreeView.ItemIndex) -> Image? {
            nil
        }
    }
}

protocol SceneListComponentDelegate: AnyObject {
    /// Method invoked whenever the user changes the selection on a scene list
    /// view.
    func sceneListComponent(
        _ component: SceneListComponent,
        didChangeSelection selection: SceneListComponent.SceneEntry
    )
}

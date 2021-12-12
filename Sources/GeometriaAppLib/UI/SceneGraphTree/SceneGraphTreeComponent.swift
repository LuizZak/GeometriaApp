import Foundation
import ImagineUI
import Blend2DRenderer

class SceneGraphTreeComponent: RaytracerUIComponent {
    private let treeView = TreeView()
    private var sceneDataSource: SceneDataSource?

    let sidePanel: SidePanel

    weak var delegate: RaytracerUIComponentDelegate?

    init(width: Double) {
        self.sidePanel = SidePanel(pinSide: .left, length: width)

        setupTreeViewEvents()
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

    func rendererChanged<T: RendererType>(anyRenderer: T) {
        let graph = anyRenderer.currentScene().walk(SceneGraphVisitor())

        updateDataSource(SceneDataSource(root: graph))
    }

    func rendererChanged<T>(_ renderer: Raymarcher<T>) {
        let graph = renderer.scene.walk(SceneGraphVisitor())

        updateDataSource(SceneDataSource(root: graph))
    }

    func mouseMoved(event: MouseEventArgs) {

    }

    private func setupTreeViewEvents() {
        treeView.mouseRightClickedItem.addListener(weakOwner: self) { [weak self] (sender, index) in
            self?.onRightClickItem(index)
        }
    }

    private func onRightClickItem(_ index: TreeView.ItemIndex) {

    }

    private func updateDataSource(_ dataSource: SceneDataSource?) {
        sceneDataSource = dataSource

        treeView.dataSource = dataSource
        treeView.reloadData()
    }

    private class SceneDataSource: TreeViewDataSource {
        var root: SceneGraphTreeNode

        init(root: SceneGraphTreeNode) {
            self.root = root
        }

        func itemAt(hierarchyIndex: TreeView.HierarchyIndex) -> ItemType {
            var item = ItemType.node(root)

            for index in hierarchyIndex.indices.dropFirst() {
                item = item.indexInto(index)
            }

            return item
        }

        func hasSubItems(at index: TreeView.ItemIndex) -> Bool {
            itemAt(hierarchyIndex: index.asHierarchyIndex).hasElements()
        }

        func numberOfItems(at hierarchyIndex: TreeView.HierarchyIndex) -> Int {
            if hierarchyIndex.isRoot {
                return 1
            }

            return itemAt(hierarchyIndex: hierarchyIndex).elementCount()
        }

        func titleForItem(at index: TreeView.ItemIndex) -> AttributedText {
            let item: ItemType = itemAt(hierarchyIndex: index.asHierarchyIndex)

            switch item {
            case .node(let node):
                return AttributedText(node.title)
            case .property(let property):
                return "\(property.name): \(property.value)"
            case .subnodes:
                return "Children"
            }
        }

        func iconForItem(at index: TreeView.ItemIndex) -> Image? {
            let item: ItemType = itemAt(hierarchyIndex: index.asHierarchyIndex)

            return item.icon()
        }

        enum ItemType {
            case node(SceneGraphTreeNode)
            case property(SceneGraphTreeNode.PropertyEntry)
            case subnodes(SceneGraphTreeNode)

            func hasElements() -> Bool {
                elementCount() > 0
            }

            func elementCount() -> Int {
                switch self {
                case .node(let node):
                    var count = 1 // ID property
                    count += node.properties.count
                    count += node.subnodes.count

                    return count
                
                case .property:
                    return 0
                
                case .subnodes(let node):
                    return node.subnodes.count
                }
            }

            func indexInto(_ index: Int) -> ItemType {
                switch self {
                case .node(let node):
                    var index = index

                    if index == 0 {
                        return .property(.init(name: "Id", value: "\(node.element.id)"))
                    }
                    index -= 1

                    if index < node.properties.count {
                        return .property(node.properties[index])
                    }
                    index -= node.properties.count
                    
                    return .node(node.subnodes[index])
                
                case .property:
                    fatalError("Cannot index into a property")
                
                case .subnodes(let node):
                    return .node(node.subnodes[index])
                }
            }

            func icon() -> Image? {
                switch self {
                case .node(let node):
                    return node.icon

                case .property:
                    return nil

                case .subnodes:
                    return nil
                }
            }
        }
    }
}

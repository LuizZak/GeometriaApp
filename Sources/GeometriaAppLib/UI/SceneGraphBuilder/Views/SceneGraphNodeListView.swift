import ImagineUI

public class SceneGraphNodeListView {
    weak var dataSource: SceneGraphNodeListViewDataSource?

    func reloadData() {

    }
}

protocol SceneGraphNodeListViewDataSource: AnyObject {
    // MARK: - Section

    func sceneGraphNodeListViewSectionCount(
        _ listView: SceneGraphNodeListView
    ) -> Int

    // MARK: - Items

    func sceneGraphNodeListView(
        _ listView: SceneGraphNodeListView,
        itemsInSection section: Int
    ) -> Int
}

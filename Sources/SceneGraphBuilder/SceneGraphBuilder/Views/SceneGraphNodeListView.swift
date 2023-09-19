import ImagineUI

public class SceneGraphNodeListView: View {
    private var _scrollView: ScrollView = .init(scrollBarsMode: .vertical)

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

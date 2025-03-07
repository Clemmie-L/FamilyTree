import UIKit

public protocol TreeViewAdapter: AnyObject {
    associatedtype T: TreeNodeIdentifiable
    
    // 数据和视图相关
    var rootNode: TreeNode<T> { get }
    func createView(for node: TreeNode<T>) -> UIView
    
    // 连接线样式配置（可选实现）
    func configureLineDrawer(_ lineDrawer: TreeLineDrawer)
    
    // 更新节点数据（可选实现）
    func updateView(_ view: UIView, for node: TreeNode<T>)
}

public extension TreeViewAdapter {
    func configureLineDrawer(_ lineDrawer: TreeLineDrawer) {
        // 默认实现，使用系统默认样式
    }
    
    func updateView(_ view: UIView, for node: TreeNode<T>) {
        // 默认实现，使用系统默认样式
    }
}

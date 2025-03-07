import UIKit

public protocol TreeViewDelegate: AnyObject {
    // 节点交互事件
    func treeView<A: TreeViewAdapter>(_ treeView: TreeViewContainer<A>, didSelectNode node: TreeNode<A.T>)
    func treeView<A: TreeViewAdapter>(_ treeView: TreeViewContainer<A>, didLongPressNode node: TreeNode<A.T>)
}

// 提供默认实现
public extension TreeViewDelegate {
    func treeView<A: TreeViewAdapter>(_ treeView: TreeViewContainer<A>, didSelectNode node: TreeNode<A.T>) {}
    func treeView<A: TreeViewAdapter>(_ treeView: TreeViewContainer<A>, didLongPressNode node: TreeNode<A.T>) {}
}

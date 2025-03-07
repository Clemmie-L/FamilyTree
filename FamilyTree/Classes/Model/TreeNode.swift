
public protocol TreeNodeIdentifiable {
    var id: String { get }
}

public class TreeNode<T> {
    public var data: T
    public weak var parent: TreeNode?
    public var children: [TreeNode] = []
    public var depth: Int = 0
    
    // 只保留选中状态
    public private(set) var isSelected: Bool = false
    
    public init(data: T) {
        self.data = data
    }
    
    public func addChild(_ child: TreeNode) {
        children.append(child)
        child.parent = self
        updateChildrenDepth()
    }
    
    private func updateChildrenDepth() {
        func updateDepth(_ node: TreeNode, depth: Int) {
            node.depth = depth
            node.children.forEach { updateDepth($0, depth: depth + 1) }
        }
        updateDepth(self, depth: self.depth)
    }
    
    public func setSelected(_ selected: Bool) {
        isSelected = selected
    }
}

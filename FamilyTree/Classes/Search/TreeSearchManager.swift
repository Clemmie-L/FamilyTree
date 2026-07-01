import UIKit

public struct TreeSearchResult<T: TreeNodeIdentifiable> {
    let node: TreeNode<T>
    let frame: CGRect
}

public class TreeSearchManager {
    // 搜索节点
    public func searchNode<T: TreeNodeIdentifiable>(query: String, searchById: Bool = false, in rootNode: TreeNode<T>) -> [TreeNode<T>] {
        var results: [TreeNode<T>] = []
        
        func search(node: TreeNode<T>) {
            // 根据搜索类型检查节点
            if searchById {
                if node.data.id == query {
                    results.append(node)
                }
            } else {
                if node.data.name.lowercased().contains(query.lowercased()) {
                    results.append(node)
                }
            }
            
            // 递归搜索子节点
            for child in node.children {
                search(node: child)
            }
        }
        
        search(node: rootNode)
        return results
    }
    
    // 获取节点在视图中的位置和大小
    public func getNodeFrame<T: TreeNodeIdentifiable>(for node: TreeNode<T>, in layoutManager: TreeLayoutManager, nodeSizes: [String: CGSize]) -> CGRect? {
        guard let position = layoutManager.nodePositions[node.data.id],
              let size = nodeSizes[node.data.id] else { return nil }
        
        return CGRect(x: position.x, y: position.y, width: size.width, height: size.height)
    }
}
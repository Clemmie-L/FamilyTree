import UIKit

public class TreeLayoutManager {
    // 修改属性访问级别为 internal
    let nodeWidth: CGFloat = 140
    let nodeHeight: CGFloat = 44
    let horizontalSpacing: CGFloat = 60
    let verticalSpacing: CGFloat = 100
    let minMargin: CGFloat = 60
    
    // 修改为 internal 访问级别
    var nodePositions: [String: CGPoint] = [:]
    private var levelNodesInfo: [Int: [String]] = [:]
    private var totalContentWidth: CGFloat = 0
    private var totalContentHeight: CGFloat = 0
    
    // 第一遍遍历：收集层级信息
    private func collectLevelInfo<T: TreeNodeIdentifiable>(node: TreeNode<T>, level: Int) {
        if levelNodesInfo[level] == nil {
            levelNodesInfo[level] = []
        }
        levelNodesInfo[level]?.append(node.data.id)
        
        for child in node.children {
            collectLevelInfo(node: child, level: level + 1)
        }
    }
    
    // 计算节点位置
    private func calculateNodePositions<T: TreeNodeIdentifiable>(node: TreeNode<T>, level: Int) {
        let nodesInCurrentLevel = levelNodesInfo[level]?.count ?? 1
        let currentLevelNodes = levelNodesInfo[level] ?? []
        let currentNodeIndex = currentLevelNodes.firstIndex(of: node.data.id) ?? 0
        
        // 计算当前层级的总宽度
        let levelWidth = CGFloat(nodesInCurrentLevel) * nodeWidth + 
                        CGFloat(nodesInCurrentLevel - 1) * horizontalSpacing
        
        // 确保总内容宽度足够
        totalContentWidth = max(totalContentWidth, levelWidth + minMargin * 2)
        
        // 计算起始X坐标（居中对齐）
        let startX = (totalContentWidth - levelWidth) / 2
        
        // 计算当前节点的X和Y坐标
        let x = startX + CGFloat(currentNodeIndex) * (nodeWidth + horizontalSpacing)
        let y = CGFloat(level) * (nodeHeight + verticalSpacing) + minMargin
        
        // 保存节点位置
        nodePositions[node.data.id] = CGPoint(x: x, y: y)
        
        // 递归处理子节点
        for child in node.children {
            calculateNodePositions(node: child, level: level + 1)
        }
    }
    
    // 公共布局方法
    public func layout<A: TreeViewAdapter>(container: TreeViewContainer<A>, adapter: A?) where A.T: TreeNodeIdentifiable {
        guard let adapter = adapter else { return }
        
        // 清除之前的布局数据
        nodePositions.removeAll()
        levelNodesInfo.removeAll()
        
        let rootNode = adapter.rootNode
        
        // 第一遍：收集层级信息
        collectLevelInfo(node: rootNode, level: 0)
        
        // 预设最小内容宽度
        totalContentWidth = UIScreen.main.bounds.width * 1.5
        
        // 第二遍：计算节点位置
        calculateNodePositions(node: rootNode, level: 0)
        
        // 更新内容高度
        let maxY = nodePositions.values.map { $0.y }.max() ?? 0
        totalContentHeight = maxY + nodeHeight + minMargin
        
        // 创建节点视图
        createNodeViews(container: container, adapter: adapter)
        
        // 绘制连接线
        drawLines(container: container, adapter: adapter)
    }
    
    // 创建节点视图
    private func createNodeViews<A: TreeViewAdapter>(container: TreeViewContainer<A>, adapter: A) where A.T: TreeNodeIdentifiable {
        func createNodeView(for node: TreeNode<A.T>) {
            guard let position = nodePositions[node.data.id] else { return }
            
            let nodeView = adapter.createView(for: node)
            container.contentView.addSubview(nodeView)
            
            nodeView.frame = CGRect(
                x: position.x,
                y: position.y,
                width: nodeWidth,
                height: nodeHeight
            )
            
            node.children.forEach { createNodeView(for: $0) }
        }
        
        createNodeView(for: adapter.rootNode)
    }
    
    // 绘制连接线
    private func drawLines<A: TreeViewAdapter>(container: TreeViewContainer<A>, adapter: A) where A.T: TreeNodeIdentifiable {
        let lineDrawer = TreeLineDrawer()
        // 使用 adapter 配置连接线样式
        adapter.configureLineDrawer(lineDrawer)
        
        func drawNodeLines(for node: TreeNode<A.T>) {
            guard let parentPosition = nodePositions[node.data.id] else { return }
            
            for child in node.children {
                guard let childPosition = nodePositions[child.data.id] else { continue }
                
                let parentFrame = CGRect(
                    x: parentPosition.x,
                    y: parentPosition.y,
                    width: nodeWidth,
                    height: nodeHeight
                )
                
                let childFrame = CGRect(
                    x: childPosition.x,
                    y: childPosition.y,
                    width: nodeWidth,
                    height: nodeHeight
                )
                
                lineDrawer.drawLines(from: parentFrame, to: childFrame, in: container.contentView)
            }
            
            node.children.forEach { drawNodeLines(for: $0) }
        }
        
        drawNodeLines(for: adapter.rootNode)
    }
    
    // 公共方法和属性
    public var contentSize: CGSize {
        return CGSize(width: totalContentWidth, height: totalContentHeight)
    }
}

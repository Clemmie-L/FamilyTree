import UIKit

public class TreeLayoutManager {
    // 节点间距和边距
    let horizontalSpacing: CGFloat = 60
    let verticalSpacing: CGFloat = 100
    let minMargin: CGFloat = 60
    
    // 节点尺寸缓存
    private(set) var nodeSizes: [String: CGSize] = [:]
    
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
        let levelWidth = (levelNodesInfo[level]?.reduce(0) { sum, nodeId in
            sum + (nodeSizes[nodeId]?.width ?? 0)
        } ?? 0) + CGFloat(nodesInCurrentLevel - 1) * horizontalSpacing
        
        // 确保总内容宽度足够
        totalContentWidth = max(totalContentWidth, levelWidth + minMargin * 2)
        
        // 计算起始X坐标（居中对齐）
        let startX = (totalContentWidth - levelWidth) / 2
        
        // 计算当前节点的X和Y坐标
        let previousNodesWidth = levelNodesInfo[level]?[..<currentNodeIndex].reduce(0) { sum, nodeId in
            sum + (nodeSizes[nodeId]?.width ?? 0) + horizontalSpacing
        } ?? 0
        let x = startX + previousNodesWidth
        let y = CGFloat(level) * (verticalSpacing + (levelNodesInfo[level]?.compactMap { nodeSizes[$0]?.height }.max() ?? 0)) + minMargin
        
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
        nodeSizes.removeAll()
        totalContentWidth = 0
        totalContentHeight = 0
        
        // 预先创建所有节点视图并获取尺寸
        func collectNodeSizes(node: TreeNode<A.T>) {
            let nodeView = adapter.createView(for: node)
            let size = nodeView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            nodeSizes[node.data.id] = size
            for child in node.children {
                collectNodeSizes(node: child)
            }
        }
        
        // 预先创建所有节点视图并获取尺寸
        collectNodeSizes(node: adapter.rootNode)
        
        let rootNode = adapter.rootNode
        
        // 第一遍：收集层级信息
        collectLevelInfo(node: rootNode, level: 0)
        
        // 计算每一层的最大宽度
        var maxLevelWidth: CGFloat = 0
        for (_, nodeIds) in levelNodesInfo {
            let levelWidth = nodeIds.reduce(0) { sum, nodeId in
                sum + (nodeSizes[nodeId]?.width ?? 0)
            } + CGFloat(nodeIds.count - 1) * horizontalSpacing
            maxLevelWidth = max(maxLevelWidth, levelWidth)
        }
        
        // 设置内容宽度，确保足够容纳所有节点
        totalContentWidth = max(UIScreen.main.bounds.width * 1.5, maxLevelWidth + minMargin * 2)
        
        // 第二遍：计算节点位置
        calculateNodePositions(node: rootNode, level: 0)
        
        // 更新内容高度
        let maxY = nodePositions.values.map { $0.y }.max() ?? 0
        let maxHeight = levelNodesInfo.values.compactMap { nodeIds in
            nodeIds.compactMap { nodeSizes[$0]?.height }.max()
        }.max() ?? 0
        totalContentHeight = maxY + maxHeight + minMargin
        
        // 创建节点视图
        createNodeViews(container: container, adapter: adapter)
        
        // 绘制连接线
        drawLines(container: container, adapter: adapter)
    }
    
    // 创建节点视图
    private func createNodeViews<A: TreeViewAdapter>(container: TreeViewContainer<A>, adapter: A) where A.T: TreeNodeIdentifiable {
        func createNodeView(for node: TreeNode<A.T>) {
            
            guard let position = nodePositions[node.data.id],
                  let size = nodeSizes[node.data.id] else { return }
            let nodeView = adapter.createView(for: node)
            container.contentView.addSubview(nodeView)
            
            nodeView.frame = CGRect(
                x: position.x,
                y: position.y,
                width: size.width,
                height: size.height
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
                
                let parentSize = nodeSizes[node.data.id] ?? .zero
                let childSize = nodeSizes[child.data.id] ?? .zero
                
                let parentFrame = CGRect(
                    x: parentPosition.x,
                    y: parentPosition.y,
                    width: parentSize.width,
                    height: parentSize.height
                )
                
                let childFrame = CGRect(
                    x: childPosition.x,
                    y: childPosition.y,
                    width: childSize.width,
                    height: childSize.height
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

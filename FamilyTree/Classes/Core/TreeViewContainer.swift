import UIKit
import SnapKit

public class TreeViewContainer<A: TreeViewAdapter>: UIView, UIScrollViewDelegate {
    // 滚动视图
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    // 内容视图
    public let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private var layoutManager: TreeLayoutManager
    private var lineDrawer: TreeLineDrawer
    private var adapter: A?
    public weak var delegate: (any TreeViewDelegate)?
    
    // 添加视图到节点的映射字典
    private var viewToNodeMap: [UIView: TreeNode<A.T>] = [:]
    
    public override init(frame: CGRect) {
        self.layoutManager = TreeLayoutManager()
        self.lineDrawer = TreeLineDrawer()
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        self.layoutManager = TreeLayoutManager()
        self.lineDrawer = TreeLineDrawer()
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // 配置滚动视图
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.bouncesZoom = true
        
        // 添加滚动视图
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 添加内容视图到滚动视图
        scrollView.addSubview(contentView)
        
        // 添加双击手势
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGesture)
        
        // 添加单击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.require(toFail: doubleTapGesture)
        contentView.addGestureRecognizer(tapGesture)
        
        // 添加长按手势
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        contentView.addGestureRecognizer(longPressGesture)
    }
    
    // 添加双击缩放功能
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale > 0.5 {
            // 如果当前缩放大于0.5，则缩小到0.5
            scrollView.setZoomScale(0.5, animated: true)
        } else {
            // 否则放大到1.0
            scrollView.setZoomScale(1.0, animated: true)
        }
    }
    
    // 简化后的点击处理
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: contentView)
        if let (node, view) = findNodeAndView(at: location) {
            // 更新节点状态
            node.setSelected(!node.isSelected)
            
            // 只通过 delegate 触发事件
            delegate?.treeView(self, didSelectNode: node)
            // 添加选中效果动画
            UIView.animate(withDuration: 0.15, animations: {
                view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.15) {
                    view.transform = .identity
                }
            }
        }
    }
    
    // 简化后的长按处理
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let location = gesture.location(in: contentView)
        if let (node, _) = findNodeAndView(at: location) {
            // 只通过 delegate 触发事件
            delegate?.treeView(self, didLongPressNode: node)
            
            // 添加触感反馈
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
    
    // 查找触摸位置对应的节点和视图
    private func findNodeAndView(at location: CGPoint) -> (TreeNode<A.T>, UIView)? {
        for subview in contentView.subviews {
            if subview.frame.contains(location) {
                if let node = viewToNodeMap[subview] {
                    return (node, subview)
                }
            }
        }
        return nil
    }
    
    public func setAdapter(_ adapter: A) {
        self.adapter = adapter
        reloadData()
    }
    
    // 更新指定节点的视图
    public func updateNodeView(_ view: UIView, for node: TreeNode<A.T>) {
        if let adapter = adapter {
            adapter.updateView(view, for: node)
        }
    }
    
    // 更新指定节点的视图
    public func updateNode(_ node: TreeNode<A.T>) {
        for (view, mappedNode) in viewToNodeMap {
            if mappedNode.data.id == node.data.id {
                updateNodeView(view, for: node)
                break
            }
        }
    }
    
    public func reloadData() {
        viewToNodeMap.removeAll()
        // 清除现有视图
        contentView.subviews.forEach { $0.removeFromSuperview() }
        contentView.layer.sublayers?.forEach {
            if $0 is CAShapeLayer {
                $0.removeFromSuperlayer()
            }
        }
        
        // 重新布局
        layoutManager.layout(container: self, adapter: adapter)
        
        // 创建节点视图
        if let adapter = adapter {
            createNodeViews(container: self, adapter: adapter)
        }
        
        // 获取内容大小
        let contentSize = layoutManager.contentSize
        
        // 更新内容视图大小
        contentView.frame = CGRect(x: 0, y: 0,
                                 width: contentSize.width,
                                 height: contentSize.height)
        scrollView.contentSize = contentView.frame.size
        
        // 计算最小缩放比例 - 只根据宽度计算
        let minScale = UIScreen.main.bounds.width / contentView.bounds.width
        
        // 设置缩放范围
        scrollView.minimumZoomScale = min(minScale, 0.5)
        scrollView.maximumZoomScale = 2.0
        
        // 设置初始缩放
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let initialScale = min(0.5, self.scrollView.minimumZoomScale)
            self.scrollView.setZoomScale(initialScale, animated: false)
        }
    }
    
    private func centerContent() {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        
        scrollView.contentInset = UIEdgeInsets(top: offsetY,
                                             left: offsetX,
                                             bottom: offsetY,
                                             right: offsetX)
    }
    
    // MARK: - UIScrollViewDelegate
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerContent()
    }
    
    // 将 createNodeViews 改为私有方法
    private func createNodeViews(container: TreeViewContainer<A>, adapter: A) {
        func createNodeView(for node: TreeNode<A.T>) {
            guard let position = layoutManager.nodePositions[node.data.id] else { return }
            
            let nodeView = adapter.createView(for: node)
            container.contentView.addSubview(nodeView)
            
            // 存储视图和节点的关系
            viewToNodeMap[nodeView] = node
            
            nodeView.frame = CGRect(
                x: position.x,
                y: position.y,
                width: layoutManager.nodeWidth,
                height: layoutManager.nodeHeight
            )
            
            node.children.forEach { createNodeView(for: $0) }
        }
        
        // 清除之前的映射
        viewToNodeMap.removeAll()
        
        createNodeView(for: adapter.rootNode)
    }
    
    // 处理视图释放
    deinit {
        viewToNodeMap.removeAll()
    }
}

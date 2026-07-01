import UIKit
import SnapKit

public class TreeViewContainer<A: TreeViewAdapter>: UIView, UIScrollViewDelegate {
    // 滚动视图
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    // 内容视图
    public let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private var layoutManager: TreeLayoutManager
    private var lineDrawer: TreeLineDrawer
    private var adapter: A?
    private let searchManager = TreeSearchManager()
    private var searchResultView: UIView?
    
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
        contentView.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.size.equalTo(CGSize.zero)
        }
        
        // 添加双击手势
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGesture)

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
    
    public func setAdapter(_ adapter: A) {
        self.adapter = adapter
        reloadData()
    }
    
    public func reloadData() {
        
        // 清除现有视图
        contentView.subviews.forEach { $0.removeFromSuperview() }
        contentView.layer.sublayers?.forEach {
            if $0 is CAShapeLayer {
                $0.removeFromSuperlayer()
            }
        }
        
        // 重新布局
        layoutManager.layout(container: self, adapter: adapter)
        
        // 获取内容大小
        let contentSize = layoutManager.contentSize
        
        // 更新内容视图大小，确保足够容纳所有内容
        let contentFrame = CGRect(x: 0, y: 0,
                                 width: max(contentSize.width, bounds.width),
                                 height: max(contentSize.height, bounds.height))
        
        contentView.snp.updateConstraints { make in
            make.size.equalTo(contentFrame.size)
        }
        
        scrollView.contentSize = contentFrame.size
        
        // 计算最小缩放比例，考虑宽度和高度
        let widthScale = bounds.width / contentFrame.width
        let heightScale = bounds.height / contentFrame.height
        
        let minScale = min(widthScale, heightScale)
        
        // 设置缩放范围
        scrollView.minimumZoomScale = max(minScale * 0.8, 0.3)
        scrollView.maximumZoomScale = 2.0
        
        // 设置初始缩放并居中内容
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let initialScale = min(0.8, self.scrollView.minimumZoomScale)
            self.scrollView.setZoomScale(initialScale, animated: false)
            self.centerContent()
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
    
    // 搜索节点
    public func searchNode(name: String) {
        guard let adapter = adapter else { return }
        
        // 移除之前的搜索结果视图
        searchResultView?.removeFromSuperview()
        searchResultView = nil
        
        // 执行搜索
        let searchResults = searchManager.searchNode(query: name, in: adapter.rootNode)
        
        guard let firstResult = searchResults.first,
              let frame = searchManager.getNodeFrame(for: firstResult, in: layoutManager, nodeSizes: layoutManager.nodeSizes) else { return }
        
        // 创建高亮视图
        let highlightView = UIView(frame: frame)
        highlightView.layer.borderColor = UIColor.systemBlue.cgColor
        highlightView.layer.borderWidth = 2
        highlightView.layer.cornerRadius = 5
        highlightView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        contentView.addSubview(highlightView)
        searchResultView = highlightView
        
        // 计算目标缩放比例和位置
        let targetScale = min(scrollView.maximumZoomScale, max(scrollView.minimumZoomScale, 1.0))
        let targetRect = frame.insetBy(dx: -50, dy: -50) // 在节点周围添加一些边距
        
        // 动画过渡到目标位置和缩放
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.scrollView.setZoomScale(targetScale, animated: false)
            self.scrollView.scrollRectToVisible(targetRect, animated: false)
        }
    }
}

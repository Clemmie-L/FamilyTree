import UIKit

public class TreeLineDrawer {
    // 线条样式配置
    public var lineColor: UIColor = .systemGray3
    public var lineWidth: CGFloat = 1.5
    public var animationDuration: TimeInterval = 0.3
    
    // 虚线样式配置
    public var isDashed: Bool = true {
        didSet {
            updateDashPattern()
        }
    }
    public var dashLength: CGFloat = 6 {
        didSet {
            updateDashPattern()
        }
    }
    public var dashSpacing: CGFloat = 4 {
        didSet {
            updateDashPattern()
        }
    }
    private var lineDashPattern: [NSNumber]? = [6, 4]
    
    // 箭头样式配置
    public var showArrow: Bool = false
    public var arrowSize: CGFloat = 10
    
    private func updateDashPattern() {
        lineDashPattern = isDashed ? [NSNumber(value: Float(dashLength)), NSNumber(value: Float(dashSpacing))] : nil
    }
    
    public func drawLines(from parentFrame: CGRect, to childFrame: CGRect, in view: UIView) {
        let lineLayer = CAShapeLayer()
        lineLayer.strokeColor = lineColor.cgColor
        lineLayer.lineWidth = lineWidth
        lineLayer.lineDashPattern = lineDashPattern
        lineLayer.fillColor = nil
        lineLayer.lineCap = .round
        lineLayer.shouldRasterize = true  // 启用光栅化
        lineLayer.rasterizationScale = UIScreen.main.scale  // 设置光栅化比例
        
        var path = UIBezierPath()
        
        // 计算连接点
        let startPoint = CGPoint(x: parentFrame.midX, y: parentFrame.maxY)
        let endPoint = CGPoint(x: childFrame.midX, y: childFrame.minY)
        
        // 计算控制点来创建平滑的曲线
        let controlPointOffset = (endPoint.y - startPoint.y) / 2
        let controlPoint1 = CGPoint(x: startPoint.x, y: startPoint.y + controlPointOffset)
        let controlPoint2 = CGPoint(x: endPoint.x, y: endPoint.y - controlPointOffset)
        
        // 绘制三次贝塞尔曲线
        path.move(to: startPoint)
        path.addCurve(to: endPoint,
                     controlPoint1: controlPoint1,
                     controlPoint2: controlPoint2)
        
        // 如果需要绘制箭头
        if showArrow {
            let arrowLayer = CAShapeLayer()
            arrowLayer.fillColor = lineColor.cgColor
            arrowLayer.strokeColor = lineColor.cgColor
            arrowLayer.shouldRasterize = true  // 启用光栅化
            arrowLayer.rasterizationScale = UIScreen.main.scale  // 设置光栅化比例
            
            // 计算箭头方向
            let endTangent = CGPoint(x: endPoint.x - controlPoint2.x,
                                    y: endPoint.y - controlPoint2.y)
            let angle = atan2(endTangent.y, endTangent.x)
            
            // 计算箭头底边的两个端点
            let arrowBaseLeft = CGPoint(x: endPoint.x - arrowSize * cos(angle - .pi/6),
                                       y: endPoint.y - arrowSize * sin(angle - .pi/6))
            let arrowBaseRight = CGPoint(x: endPoint.x - arrowSize * cos(angle + .pi/6),
                                        y: endPoint.y - arrowSize * sin(angle + .pi/6))
            
            // 计算箭头底边的中点作为新的终点
            let newEndPoint = CGPoint(x: (arrowBaseLeft.x + arrowBaseRight.x) / 2,
                                     y: (arrowBaseLeft.y + arrowBaseRight.y) / 2)
            
            // 创建箭头路径
            let arrowPath = UIBezierPath()
            arrowPath.move(to: endPoint)
            arrowPath.addLine(to: arrowBaseLeft)
            arrowPath.addLine(to: arrowBaseRight)
            arrowPath.close()
            
            arrowLayer.path = arrowPath.cgPath
            view.layer.addSublayer(arrowLayer)
            
            // 为箭头添加渐现动画
            let arrowAnimation = CABasicAnimation(keyPath: "opacity")
            arrowAnimation.duration = animationDuration
            arrowAnimation.fromValue = 0
            arrowAnimation.toValue = 1
            arrowAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            arrowLayer.add(arrowAnimation, forKey: "arrowAnimation")
            
            // 更新连接线的终点为箭头底边的中点
            path = UIBezierPath()
            path.move(to: startPoint)
            path.addCurve(to: newEndPoint,
                         controlPoint1: controlPoint1,
                         controlPoint2: CGPoint(x: newEndPoint.x,
                                               y: newEndPoint.y - controlPointOffset))
        }
        
        lineLayer.path = path.cgPath
        
        // 添加线条动画
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = animationDuration
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        lineLayer.add(animation, forKey: "lineAnimation")
        
        view.layer.addSublayer(lineLayer)
    }
}

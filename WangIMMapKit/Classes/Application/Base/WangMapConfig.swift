//
//  WangMapConfig.swift
//  WangIMMapKit
//
//  Created by Wang on 2025/5/15.
//

import Foundation
import UIKit
import Kingfisher
import SnapKit

import AMapLocationKit
import MAMapKit
import AMapSearchKit


let darkStyle = UITraitCollection.current.userInterfaceStyle

/// 屏幕工具结构体，统一管理与屏幕尺寸、安全区域、导航栏等相关的常量
struct Screen {
    /// 屏幕宽度
    static let width: CGFloat = UIScreen.main.bounds.width
    
    /// 屏幕高度
    static let height: CGFloat = UIScreen.main.bounds.height
    
    /// 当前设备的安全区域（刘海屏/全面屏会有额外的 inset）
    static var safeInsets: UIEdgeInsets {
        return UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
    }

    /// 是否是带有刘海的 iPhone 机型（如 iPhone X 及以上）
    static var isIPhoneX: Bool {
        return safeInsets.top > 20
    }
    
    /// 状态栏高度（普通设备一般为 20pt，刘海屏为 44pt）
    static var statusBarHeight: CGFloat {
        return safeInsets.top
    }

    /// 标准导航栏高度，固定为 44pt
    static let navBarHeight: CGFloat = 44.0

    /// 导航栏 + 状态栏 总高度
    static var navBarTotalHeight: CGFloat {
        return statusBarHeight + navBarHeight
    }

    /// TabBar 高度，标准高度为 49pt
    static let tabBarHeight: CGFloat = 49.0

    /// 底部安全区高度（刘海屏为 34pt，非刘海屏为 0）
    static var safeAreaBottomHeight: CGFloat {
        return isIPhoneX ? 34.0 : 0.0
    }
}

extension UIColor {
    
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// 黑色
    static func titleColor() -> UIColor {
        return UIColor.init(hex: "#333333", alpha: 1.0)
    }
    /// 字体灰色
    static func subTitleColor() -> UIColor {
        return UIColor.init(hex: "#999999", alpha: 1.0)
    }
    
    /// 背景灰
    static func backgroundGrayColor() -> UIColor {
        return UIColor.init(hex: "#E3E3E3", alpha: 1.0)
    }
    /// 背景灰 透明40%
    static func backgroundGrayColor40() -> UIColor {
        return UIColor.init(hex: "#E3E3E3", alpha: 0.4)
    }
    /// 白色 透明20%
    static func whiteColor20() -> UIColor {
        return UIColor.init(hex: "#FFFFFF", alpha: 0.2)
    }
    
    /// 按钮灰
    static func buttonGrayColor() -> UIColor {
        return UIColor.init(hex: "#EFEFEF", alpha: 1.0)
    }
    
    /// 红色
    static func backgoundRed() -> UIColor {
        return UIColor.init(hex: "#FF0000", alpha: 1.0)
    }
    
}

extension UIFont {
    static func regular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func medium(_ size: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }
    
    static func bold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Semibold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
    
    
    static func regular16() -> UIFont {
        return regular(16)
    }
    
    static func regular14() -> UIFont {
        return regular(14)
    }
    
    static func regular12() -> UIFont {
        return regular(12)
    }
    
    static func regular10() -> UIFont {
        return regular(10)
    }
    
    static func medium16() -> UIFont {
        return medium(16)
    }
    
    static func medium14() -> UIFont {
        return medium(14)
    }
    
    static func medium12() -> UIFont {
        return medium(12)
    }
    
    static func medium10() -> UIFont {
        return medium(10)
    }
    
    static func bold16() -> UIFont {
        return bold(16)
    }
    
    static func bold14() -> UIFont {
        return bold(14)
    }
    
    static func bold12() -> UIFont {
        return bold(12)
    }
    
    static func bold10() -> UIFont {
        return bold(10)
    }
}

extension UIView {
    
    // x 坐标
    var x: CGFloat {
        get { return frame.origin.x }
        set { frame.origin.x = newValue }
    }
    
    // y 坐标
    var y: CGFloat {
        get { return frame.origin.y }
        set { frame.origin.y = newValue }
    }
    
    // 宽度
    var width: CGFloat {
        get { return frame.size.width }
        set { frame.size.width = newValue }
    }
    
    // 高度
    var height: CGFloat {
        get { return frame.size.height }
        set { frame.size.height = newValue }
    }
    
    // 视图中心点 X 坐标
    var centerX: CGFloat {
        get { return center.x }
        set { center.x = newValue }
    }
    
    // 视图中心点 Y 坐标
    var centerY: CGFloat {
        get { return center.y }
        set { center.y = newValue }
    }
    
    // 右侧最大 x 值（右边界）
    var maxX: CGFloat {
        return frame.origin.x + frame.size.width
    }
    
    // 底部最大 y 值（底部边界）
    var maxY: CGFloat {
        return frame.origin.y + frame.size.height
    }
    
    /// 裁剪视图指定的角，并设置边框颜色（适用于 SnapKit 约束）
    /// - Parameters:
    ///   - corners: 需要裁剪的角，默认所有角 `.allCorners`
    ///   - radius: 圆角半径
    ///   - borderWidth: 边框宽度（可选）
    ///   - borderColor: 边框颜色（可选）
    func roundCorners(corners: UIRectCorner = .allCorners, radius: CGFloat, borderWidth: CGFloat = 0, borderColor: UIColor = .clear) {
        
        layoutIfNeeded()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.bounds.size != .zero else { return }
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            self.layer.mask = maskLayer
            
            // 移除旧的边框，避免叠加
            self.layer.sublayers?.removeAll(where: { $0 is CAShapeLayer && $0 != maskLayer })
            if borderWidth > 0 {
                let borderLayer = CAShapeLayer()
                borderLayer.path = path.cgPath
                borderLayer.lineWidth = borderWidth * 2 // 由于路径在中心，需加倍宽度
                borderLayer.strokeColor = borderColor.cgColor
                borderLayer.fillColor = UIColor.clear.cgColor
                borderLayer.frame = self.bounds
                self.layer.addSublayer(borderLayer)
            }
        }
    }
    
    /// 设置不同角的不同圆角大小（适用于 SnapKit）
    /// - Parameters:
    ///   - topLeft: 左上角的圆角大小
    ///   - topRight: 右上角的圆角大小
    ///   - bottomLeft: 左下角的圆角大小
    ///   - bottomRight: 右下角的圆角大小
    func roundCornerRadii(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
        layoutIfNeeded() // 确保 bounds 已计算
        
        let path = UIBezierPath()
        let rect = bounds
        let maskLayer = CAShapeLayer()
        
        let corners: [(CGFloat, CGPoint, CGFloat, CGFloat)] = [
            (topLeft, CGPoint(x: rect.minX, y: rect.minY), CGFloat.pi, 1.5 * CGFloat.pi),
            (topRight, CGPoint(x: rect.maxX, y: rect.minY), 1.5 * CGFloat.pi, 0),
            (bottomRight, CGPoint(x: rect.maxX, y: rect.maxY), 0, 0.5 * CGFloat.pi),
            (bottomLeft, CGPoint(x: rect.minX, y: rect.maxY), 0.5 * CGFloat.pi, CGFloat.pi)
        ]
        
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
        
        for (radius, center, startAngle, endAngle) in corners {
            if radius > 0 {
                let arcCenter = CGPoint(
                    x: center.x + (center.x == rect.minX ? radius : -radius),
                    y: center.y + (center.y == rect.minY ? radius : -radius)
                )
                path.addArc(withCenter: arcCenter,
                            radius: radius,
                            startAngle: startAngle,
                            endAngle: endAngle,
                            clockwise: true)
            } else {
                path.addLine(to: center)
            }
        }
        
        path.close()
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
}

// 工具类封装
public class PodResourceLoader {
    public static var bundle: Bundle {
        let bundle = Bundle(for: PodResourceLoader.self)
        guard let url = bundle.url(forResource: "WangIMMapKit", withExtension: "bundle"),
              let resourceBundle = Bundle(url: url) else {
            fatalError("资源 Bundle 加载失败")
        }
        return resourceBundle
    }
    
    public static func image(named name: String) -> UIImage? {
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
}

extension UIViewController {
    /// 判断是否通过 push 进入
    var isPushed: Bool {
        // 是否存在于导航栈中，且导航控制器未被 present
        guard let nav = navigationController, nav.viewControllers.contains(self) else {
            return false
        }
        return nav.presentingViewController == nil
    }
    
    /// 判断是否通过 present 进入
    var isPresented: Bool {
        // 检查自身或父控制器的 presentingViewController 是否存在
        var currentVC: UIViewController? = self
        while let vc = currentVC {
            if vc.presentingViewController != nil {
                return true
            }
            currentVC = vc.parent
        }
        return false
    }
}

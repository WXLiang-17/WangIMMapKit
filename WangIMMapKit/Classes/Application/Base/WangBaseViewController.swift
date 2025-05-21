import UIKit

public class WangBaseViewController: UIViewController {
    // MARK: - 配置参数
    /// 是否隐藏状态栏 (默认不隐藏)
    public var shouldHideStatusBar: Bool = false
    
    /// 是否隐藏导航栏底部阴影线 (默认隐藏)
    public var shouldHideNavBarShadow: Bool = true
    
    // MARK: - 状态管理
    private var originalNavBarHidden: Bool?
    private var originalNavBarTranslucent: Bool?
    private var originalNavBarShadowImage: UIImage?
    private var originalNavBarBackgroundImage: UIImage?
    
    // MARK: - 生命周期
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        saveNavigationBarState()
        handleNavigationBar(animated: animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        restoreNavigationBarState(animated: animated)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableInteractivePopGesture()
    }
    
    // MARK: - 基础配置
    func setupUI() {
        
    }
}

// MARK: - 核心功能实现

extension WangBaseViewController {
    // 保存导航栏原始状态
    private func saveNavigationBarState() {
        guard let nav = navigationController else { return }
        
        originalNavBarHidden = nav.isNavigationBarHidden
        originalNavBarTranslucent = nav.navigationBar.isTranslucent
        originalNavBarShadowImage = nav.navigationBar.shadowImage
        originalNavBarBackgroundImage = nav.navigationBar.backgroundImage(for: .default)
    }
    
    // 处理导航栏显示逻辑
    private func handleNavigationBar(animated: Bool) {
        guard let nav = navigationController else { return }
        
        nav.setNavigationBarHidden(true, animated: animated)
        nav.navigationBar.isTranslucent = true
        
        if shouldHideNavBarShadow {
            nav.navigationBar.shadowImage = UIImage()
            nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
        }
        
        adjustSafeAreaInsets()
    }
    
    // 恢复导航栏状态
    private func restoreNavigationBarState(animated: Bool) {
        guard let nav = navigationController else { return }
        
        let shouldHide = originalNavBarHidden ?? false
        let shouldTranslucent = originalNavBarTranslucent ?? false
        
        nav.setNavigationBarHidden(shouldHide, animated: animated)
        nav.navigationBar.isTranslucent = shouldTranslucent
        nav.navigationBar.shadowImage = originalNavBarShadowImage
        nav.navigationBar.setBackgroundImage(originalNavBarBackgroundImage, for: .default)
    }
    
    // 调整安全区域
    private func adjustSafeAreaInsets() {
        additionalSafeAreaInsets = UIEdgeInsets(
            top: -view.safeAreaInsets.top,
            left: 0,
            bottom: 0,
            right: 0
        )
    }
}

// MARK: - 扩展功能

extension WangBaseViewController {
    // 状态栏控制
    public override var prefersStatusBarHidden: Bool {
        return shouldHideStatusBar
    }
    
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    // 全屏沉浸式模式
    func enableFullscreenMode() {
        shouldHideStatusBar = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    // 滚动视图适配
    func adaptScrollView(_ scrollView: UIScrollView) {
        scrollView.contentInsetAdjustmentBehavior = .never
    }
}

// MARK: - 手势支持

extension WangBaseViewController: UIGestureRecognizerDelegate {
    private func enableInteractivePopGesture() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}

//
//  WangSendMapViewController.swift
//  WangIMMapKit
//
//  Created by Wang on 2025/5/15.
//

import UIKit
import AMapLocationKit
import MAMapKit
import AMapSearchKit

public protocol WangSendMapViewControllerDelegate: AnyObject {
    func didTapSendMapLocatiom(resultModel: WangSendLocationModel)
}

public class WangSendMapViewController: WangBaseViewController {
    public weak var delegate: WangSendMapViewControllerDelegate?
    
    private let options = AMapOptions()
    lazy var centerPin: UIImageView = {
        let centerImageView = UIImageView()
        centerImageView.image = options.centerImage
        return centerImageView
    }()
    
    lazy var sendHeader: WangSendMapSendHeadrView = {
        let view = WangSendMapSendHeadrView()
        view.cancelButton.addTarget(self, action:#selector(sendDismissvc) , for: .touchUpInside)
        view.sendButton.addTarget(self, action: #selector(sendLocation), for: .touchUpInside)
        return view
    }()

    /// 地图
    var isLocated: Bool = false
    var isMapViewRegionChangedFromTableView: Bool = false
    lazy var mapView: MAMapView = {
        let map = MAMapView()
        map.showsUserLocation = true
        map.userTrackingMode = .none
        map.delegate = self
        map.allowsBackgroundLocationUpdates = true
        map.showsCompass = false
        map.setZoomLevel(options.mapZoomLevel, animated: true)
        return map
    }()
    /// 自定义定位小蓝点
    lazy var rep: MAUserLocationRepresentation = {
        let r = MAUserLocationRepresentation()
        r.showsAccuracyRing = false
        return r
    }()
    
    /// 是否为文字搜索
    var isSearchText: Bool = false
    lazy var locationButton: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(centerToUserLocation), for: .touchUpInside)
        btn.setImage(options.locationImage, for: .normal)
        btn.backgroundColor = options.locationBgColor
        return btn
    }()
    
    lazy var searchView: WangSearchTableView = {
        let searchView = WangSearchTableView()
        searchView.delegate = self
        return searchView
    }()
    
    
    var selectAMapPoi: AMapPOI?
    override func setupUI() {
        setupView()
        setupKeyboardObservers()
    }

    func setupView() {
        self.view.addSubview(self.searchView)
        self.searchView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(Screen.height - options.sendMapHeight)
        }
        
        self.searchView.roundCornerRadii(topLeft: 5, topRight: 5, bottomLeft: 0, bottomRight: 0)
        
        self.view.addSubview(self.mapView)
        self.mapView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(self.searchView.snp.top)
        }
        self.mapView.update(self.rep)
        self.mapView.addSubview(self.locationButton)
        self.locationButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-5)
            make.width.height.equalTo(options.locationWidth)
            make.right.equalToSuperview().offset(-15)
        }
        self.locationButton.roundCorners(radius: options.locationRadius)
        
        self.setupSendView()
        self.setupCenterPin()
    }
    
    func setupSendView() {
        /// 发送位置
        self.view.addSubview(self.sendHeader)
        self.sendHeader.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Screen.navBarTotalHeight)
        }
        
    }
    
    // MARK: - 初始化浮标
    private func setupCenterPin() {
        centerPin.contentMode = .scaleAspectFit
        centerPin.frame = CGRect(x: 0, y: 0, width: options.centerImageWidth, height: options.centerImageHeight)
        view.addSubview(centerPin)
        view.bringSubviewToFront(centerPin)
    }
    
    // MARK: - 更新浮标位置
    private func updatePinPosition() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // 获取地图中心点经纬度
            let centerCoordinate = self.mapView.centerCoordinate
            // 将经纬度转换为地图视图内的坐标（关键点）
            let mapViewCenterPoint = self.mapView.convert(centerCoordinate, toPointTo: self.mapView)
            // 转换为父视图坐标系
            let parentCenterPoint = self.mapView.convert(mapViewCenterPoint, to: self.view)
            // 更新浮标位置
            self.centerPin.center = parentCenterPoint
        }
    }
    
    // MARK: - 移动到指定 POI 的中心
    func moveToPOI(_ poi: AMapPOI) {
           // 1. 检查 POI 的坐标是否有效
           guard let location = poi.location else {
               print("错误：POI 的坐标信息为空")
               return
           }
           // 2. 转换为 CLLocationCoordinate2D
           let coordinate = CLLocationCoordinate2D(
               latitude: CLLocationDegrees(location.latitude),
               longitude: CLLocationDegrees(location.longitude))
           self.mapView.centerCoordinate = coordinate
           updatePinPosition()
           
       }
    func moveToSearch() {
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
}

// MARK：- 键盘处理
extension WangSendMapViewController {
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        self.centerPin.isHidden = true
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let convertedFrame = view.convert(keyboardFrame, from: UIScreen.main.coordinateSpace)
        let keyboardHeight = convertedFrame.height - view.safeAreaInsets.bottom
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            self.searchView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().offset(-keyboardHeight)
            }
        }
        sendButtonisEnabled(isEnabled: false)
        
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        keyboardHidden()
    }
    
    /// 显示键盘
    func keyboardShow() {
        
    }
    
    /// 收起键盘
    func keyboardHidden() {
        self.centerPin.isHidden = false
        self.searchView.snp.updateConstraints { make in
            make.bottom.equalToSuperview()
        }
        sendButtonisEnabled(isEnabled: true)
    }
    
    func sendButtonisEnabled(isEnabled: Bool) {
        let bgColor: UIColor = isEnabled ? options.sendSureBtnBgColor : .backgroundGrayColor40()
        self.sendHeader.sendButton.isUserInteractionEnabled = isEnabled
        self.sendHeader.sendButton.backgroundColor = bgColor
    }
    
    /// 回到原点
    @objc func centerToUserLocation() {
        guard let userLocation = self.mapView.userLocation.location else {
//            showAlert(title: "定位未开启", message: "请检查定位权限")
            return
        }
        self.isSearchText = false
        self.mapView.setCenter(userLocation.coordinate, animated: true)
    }
    
    
}

extension WangSendMapViewController {
    @objc func sendDismissvc() {
        if self.isPushed {
            self.navigationController?.popViewController(animated: true)
        }else if self.isPresented {
            self.dismiss(animated: true)
        }
    }
    
    @objc public func sendLocation() {
        /// 地图截图
        self.mapView.takeSnapshot(in: self.mapView.bounds, timeoutInterval: 1) { [weak self] resultImage, state in
            
            guard let mapImage = resultImage else {
                print("地图截图失败")
                return
            }
            
            
            var name: String = "未知"
            var address: String = "未知"
            var latitude: Double = 0.0
            var longitude: Double = 0.0
            
            if let mapPoi = self?.selectAMapPoi {
                name = mapPoi.name
                address = mapPoi.address
                latitude = mapPoi.location.latitude
                longitude = mapPoi.location.longitude
            }
            
            var resultModel: WangSendLocationModel = WangSendLocationModel()
            resultModel.name = name
            resultModel.address = address
            resultModel.latitude = latitude
            resultModel.longitude = longitude
            resultModel.image = mapImage
            self?.delegate?.didTapSendMapLocatiom(resultModel: resultModel)
            self?.sendDismissvc()
            
        }
    }
    
}


// MARK: - WangSearchTableViewDelegate
extension WangSendMapViewController: WangSearchTableViewDelegate{
    func searchMovePOI(poi: AMapPOI, isPoi: Bool) {
        self.selectAMapPoi = poi
        self.isSearchText = !isPoi
        if isPoi {
            self.moveToPOI(poi)
        }else {
            keyboardHidden()
            self.mapView.setCenter(CLLocationCoordinate2D(latitude: poi.location.latitude, longitude: poi.location.longitude), animated: true)
            updatePinPosition()
        }
    }
    
}

// MARK: - 地图Delegate
extension WangSendMapViewController: MAMapViewDelegate {
    
    /// 地图加载完成后设置浮标
    public func mapViewDidFinishLoadingMap(_ mapView: MAMapView!) {
        self.updatePinPosition()
    }
    // 点击地图时触发
    public func mapView(_ mapView: MAMapView, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
        // 将地图中心移动到点击位置（带动画）
        mapView.setCenter(coordinate, animated: true)
        self.updatePinPosition()
        self.searchView.searchServicePOI(locationCoordinate: coordinate)
    }
    
    // MARK: - 地图区域变化回调
    public func mapView(_ mapView: MAMapView!, regionDidChangeAnimated animated: Bool, wasUserAction: Bool) {
        
        if wasUserAction {
            self.isSearchText = false
        }
        
        if !self.isMapViewRegionChangedFromTableView && self.mapView.userTrackingMode == .none && !self.isSearchText {
            self.searchView.searchServicePOI(locationCoordinate: self.mapView.centerCoordinate)
        }
        self.isMapViewRegionChangedFromTableView = false
    }

    
    public func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        
        if !updatingLocation {
            return
        }
        if userLocation.location.horizontalAccuracy < 0 {
            return
        }
        if !self.isLocated {
            self.isLocated = true
            self.mapView.userTrackingMode = .follow
            self.mapView.centerCoordinate = userLocation.location.coordinate
//            self.searchServicePOI(locationCoordinate: userLocation.location.coordinate)
            self.searchView.searchServicePOI(locationCoordinate: userLocation.location.coordinate)
        }
    }

    public func mapViewRequireLocationAuth(_ locationManager: CLLocationManager!) {
        locationManager.requestAlwaysAuthorization()
    }
}

// MARK: - 控件
/// 发送位置的header
class WangSendMapSendHeadrView: UIView {
    
    private let options = AMapOptions()
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = options.sendCancelBtnBgColor
        button.setTitle(options.sendCancelBtnTitle, for: .normal)
        button.setTitleColor(options.sendCancelTitleColor, for: .normal)
        button.titleLabel?.font = options.sendCancelFont
        return button
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = options.sendSureBtnBgColor
        button.setTitle(options.sendSureBtnTitle, for: .normal)
        button.setTitleColor(options.sendSureTitleColor, for: .normal)
        button.titleLabel?.font = options.sendSureFont
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.addSubview(self.cancelButton)
        self.cancelButton.snp.makeConstraints { make in
            make.width.equalTo(options.sendBtnWidth)
            make.height.equalTo(options.sendBtnHeight)
            make.left.equalTo(options.sendFrameX)
            make.bottom.equalToSuperview().offset(-8)
        }
        self.cancelButton.roundCorners(radius: options.sendBtnRadius)
        self.addSubview(self.sendButton)
        self.sendButton.snp.makeConstraints { make in
            make.width.height.top.equalTo(self.cancelButton)
            make.right.equalToSuperview().offset(-options.sendFrameX)
        }
        self.sendButton.roundCorners(radius:  options.sendBtnRadius)
    }
    
}


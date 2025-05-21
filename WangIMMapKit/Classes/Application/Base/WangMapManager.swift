//
//  WangMapManager.swift
//  WangIMMapKit
//
//  Created by Wang on 2025/5/15.
//

import UIKit
import AMapFoundationKit
import MAMapKit

public class WangMapManager: NSObject {
    
    public class func initAMap(apiKey: String, mapOptions: WangMapOptions = WangMapOptions()) {
        AMapServices.shared().apiKey = apiKey
        MAMapView.updatePrivacyAgree(AMapPrivacyAgreeStatus.didAgree)
        MAMapView.updatePrivacyShow(AMapPrivacyShowStatus.didShow, privacyInfo: AMapPrivacyInfoStatus.didContain)
        AMapOptionsInfo.shared.options = mapOptions
    }
}


public class WangMapOptions: NSObject {
    /**
     地图属性设置
     */
    /// 地图的宽
    public var mapViewWidth: CGFloat = Screen.width
    public var mapZoomLevel: CGFloat = 15
    public var distanceFilter: CLLocationDistance = 10
    public var locationTimeout: Int = 2
    public var reGeocodeTimeout: Int = 2
    /**
     共享位置设置视图属性
     */
    public var shareMapHeight: CGFloat = Screen.height
    /// 头像的大小
    public var shareImageWidth: CGFloat = 50
    /// 头像白边
    public var shareImageLayerWidth: CGFloat = 0.5
    /// 颜色(注： 颜色不涉及暗黑模式，如若s适配暗黑模式，自行设置)
    /**
     发送位置设置视图属性
     */
    public var sendMapHeight: CGFloat = Screen.height / 3 * 2
    /// 发送位置确定按钮
    public var sendSureBtnBgColor: UIColor = .backgoundRed()
    public var sendSureBtnTitle: String = "确定"
    public var sendSureTitleColor: UIColor = .white
    public var sendSureFont: UIFont = .regular14()
    /// 发送位置取消按钮
    public var sendCancelBtnBgColor: UIColor = .white
    public var sendCancelBtnTitle: String = "取消"
    public var sendCancelTitleColor: UIColor = .titleColor()
    public var sendCancelFont: UIFont = .regular14()
    
    public var sendBtnWidth: CGFloat = 65
    public var sendBtnHeight: CGFloat = 35
    public var sendBtnRadius: CGFloat = 8
    /// 按钮居左右距离
    public var sendFrameX: CGFloat = 20
    /// 中心标记
//    public var centerImage: UIImage = UIImage(named: "icon_map_share_green") ?? UIImage()
    public var centerImage: UIImage = PodResourceLoader.image(named: "icon_map_share_green") ?? UIImage()
    /// 浮标的大小
    public var centerImageWidth: CGFloat = 18
    public var centerImageHeight: CGFloat = 20
    /// 回到定位按钮
    public var locationImage: UIImage = PodResourceLoader.image(named: "icon_map_location") ?? UIImage()
    public var locationWidth: CGFloat = 35
    public var locationRadius: CGFloat = 4
    public var locationBgColor: UIColor = .backgroundGrayColor()
    
    /// cell属性设置
    public var rowHeight: CGFloat = 78
    public var cellTitleColor: UIColor = .titleColor()
    public var cellTitleFont: UIFont = .regular16()
    
    public var cellSubTitleColor: UIColor = .subTitleColor()
    public var cellSubTitleFont: UIFont = .regular14()
    public var selectImageWidth: CGFloat = 25
    public var selectImage: UIImage = PodResourceLoader.image(named: "icon_map_select") ?? UIImage()
    public var separatorColor: UIColor = .backgroundGrayColor40()
    /**
     搜索框的
     */
    public var searchTitle: String = "搜索地点"
    public var searchIconImage: UIImage = PodResourceLoader.image(named: "icon_map_search") ?? UIImage()
    public var searchBgColor: UIColor = .backgroundGrayColor40()
    public var searchTitleColor: UIColor = .subTitleColor()
    public var searchTitleFont: UIFont = .regular16()
    public var searchPlaceholderColor: UIColor = .backgroundGrayColor()
}


class AMapOptionsInfo: NSObject {
    static let shared = AMapOptionsInfo()
    // 私有化初始化方法，防止外部实例化
    private override init() {}
    var options: WangMapOptions = WangMapOptions()
}


@dynamicMemberLookup
struct AMapOptions {
    private let config: WangMapOptions  // 这里替换成实际的配置类型
    init(config: WangMapOptions = AMapOptionsInfo.shared.options) {
        self.config = config
    }
    subscript<T>(dynamicMember keyPath: KeyPath<WangMapOptions, T>) -> T {
        config[keyPath: keyPath]
    }
}


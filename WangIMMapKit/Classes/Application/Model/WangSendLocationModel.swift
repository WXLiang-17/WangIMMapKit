//
//  WangSendLocationModel.swift
//  WangIMMapKit
//
//  Created by 王学良 on 2025/5/18.
//

import UIKit

public struct WangSendLocationModel {
    
    public var image: UIImage = UIImage()
    
    /// 地址
    public var address: String = ""
    /// 经纬度
    public var latitude: Double = 0
    public var longitude: Double = 0
    /// 名称
    public var name: String = ""
    
//    // MARK: - 初始化方法
//    /// 直接通过 UIImage 初始化（必须提供图片）
//    init(image: UIImage, id: String = UUID().uuidString) {
//        self.image = image
//        
//    }
}

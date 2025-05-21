//
//  ViewController.swift
//  WangIMMapKit
//
//  Created by Wang on 05/15/2025.
//  Copyright (c) 2025 Wang. All rights reserved.
//

import UIKit
import WangIMMapKit

class ViewController: UIViewController, WangSendMapViewControllerDelegate {
    func didTapSendMapLocatiom(resultModel: WangIMMapKit.WangSendLocationModel) {
        self.mapImageView.image = resultModel.image
    }

    lazy var mapImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .blue
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let btn = UIButton(frame: CGRectMake(10, 10, 100, 50))
        btn.backgroundColor = UIColor.red
        btn.center = self.view.center
        self.view.addSubview(btn)
        btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        
        self.mapImageView.frame = CGRect(x: 10, y: 10, width: 150, height: 150)
        self.mapImageView.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 150)
        self.view.addSubview(self.mapImageView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func btnClick() {
        let vc = WangSendMapViewController()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}


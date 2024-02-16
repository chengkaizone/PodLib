//
//  ISplashLoader.swift
//  AdApi
//
//  Created by tony on 2024/2/16.
//

import UIKit


/// 开屏广告加载器
public protocol ISplashLoader {

    /// 创建占位视图
    func createPlaceholder(_ window: UIWindow?)

    /// 移除占位视图
    func removePlaceholder()

    /// 加载开屏广告
    func loadSplashAd(adEnabled: Bool, keyWindow: UIWindow)


}


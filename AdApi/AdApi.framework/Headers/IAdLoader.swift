//
//  IAdLoader.swift
//  AdApi
//
//  Created by tony on 2024/2/16.
//

import UIKit

/**
 广告加载器
 */
public protocol IAdLoader {

    /**
     * 初始化
     */
    func initialize(appId: String, splashId: String, interstitialId: String,
                   bannerId: String, rewardId: String)

    /// 创建占位视图
    func createPlaceholder(_ window: UIWindow?)

    /// 移除占位视图
    func removePlaceholder()

    /// 加载开屏广告
    func loadSplashAd(adEnabled: Bool, keyWindow: UIWindow)

    /// 加载插屏广告
    /// - Parameter viewController:
    func refreshInterstitialAd(_ viewController: UIViewController)

}

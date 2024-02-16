//
//  IInterstitialLoader.swift
//  AdApi
//
//  Created by tony on 2024/2/16.
//

import UIKit


/// 开屏广告加载器
public protocol IInterstitialLoader {


    /// 刷新插屏广告
    func refreshInterstitialAd(_ viewController: UIViewController)

    /// 刷新插屏广告
    func refreshInterstitialAd(_ viewController: UIViewController, _ autoShowEnabled: Bool)


    /// 手动展示插屏广告
    func showInterstitialAd()

}

//
//  ICommonBusiness.swift
//  UICommon
//
//  Created by tony on 2024/2/17.
//

import UIKit

/// 公共UI模块协议
public protocol ICommonBusiness {
    
    /// 页面视图背景
    /// - Returns:
    func getViewBackgroundColor() -> UIColor
    
    /// 获取导航返回图标
    /// - Returns:
    func getNavBackIcon() -> UIImage
    
    /// 获取导航取消图标
    /// - Returns:
    func getNavCancelIcon() -> UIImage
    
    /// 触发应用主题改变
    func onThemeChanged()
    
    /// 获取应用主题色
    /// - Returns:
    func getPrimaryColor() -> UIColor
    
    /// 获取应用次要颜色
    /// - Returns:
    func getAccentColor() -> UIColor
    
    /// 获取应用辅助颜色
    /// - Returns:
    func getExtraColor() -> UIColor
    
    /**
     * 用户协议标题
     */
    func getUserTermsTitle() -> String

    /**
     获取用户协议地址
     */
    func getUserTermsUrl() -> String
    
    /**
     * 隐私政策标题
     */
    func getPrivacyTitle() -> String
    
    /**
     获取隐私政策地址
     */
    func getPrivacyUrl() -> String
    
    /**
     * 获取ICP
     */
    func getIcp() -> String
    
    /**
     * 获取本地化
     */
    func getLocale() -> String

    /**
     * 获取About title
     */
    func getAboutTitle() -> String
    
    /**
     * 获取App图标
     */
    func getAppIcon() -> UIImage
    
    /// 获取应用名称
    /// - Returns:
    func getAppName() -> String
    
    /**
     * 获取版本名称
     */
    func getVersionName() -> String
    
    /// 获取反馈标题
    /// - Returns:
    func getFeedbackTitle() -> String
    
    /// 获取反馈主题提示
    /// - Returns:
    func getFeedbackSubject() -> String
    
    /// 获取反馈输入提示
    /// - Returns:
    func getFeedbackContent() -> String
    
    /// 获取反馈联系人提示
    /// - Returns:
    func getFeedbackContact() -> String
    
    /// 获取提交按钮文本
    /// - Returns:
    func getSubmit() -> String
    
    /// 获取浏览器返回按钮
    /// - Returns:
    func getWebGobackImage() -> UIImage
    
    /// 获取浏览器返回选中按钮
    /// - Returns:
    func getWebGobackImageSelected() -> UIImage
    
    /// 获取浏览器前向按钮
    /// - Returns:
    func getWebGoforwardImage() -> UIImage
    
    /// 获取浏览器前向选中按钮
    /// - Returns: 
    func getWebGoforwardImageSelected() -> UIImage
    
    /// 停止开屏广告
    func stopSplash()
    
    /// 恢复开屏广告
    func resumeSplash()
    
    /// 设置应用键盘库处理
    /// - Parameter keyboardInputEnabled:
    func setKeyboardManagerAction(keyboardInputEnabled: Bool)
    
    /// 设置分析开始页面
    /// - Parameter clazzName:
    func setAnalysisBeginPageView(clazzName: String)
    
    /// 设置分析结束页面
    /// - Parameter clazzName:
    func setAnalysisEndPageView(clazzName: String)
    
    /// 设置手势返回
    /// - Parameter isFlashbackEnabled:
    func setFlashbackAction(isFlashbackEnabled: Bool)
    
    /// 用户反馈
    /// - Parameters:
    ///   - title:
    ///   - content:
    ///   - contact:
    func addFeedback(controller: UIViewController, title: String, content: String, contact: String)
    
    /// 页面吐司提醒
    /// - Parameters:
    ///   - hint: 
    ///   - controller:
    ///   - delay:
    func showHint(_ hint: String, controller: UIViewController, delay: Double)
    
}

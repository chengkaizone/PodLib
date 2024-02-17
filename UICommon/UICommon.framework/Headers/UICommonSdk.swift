//
//  UICommonSdk.swift
//  UICommon
//
//  Created by tony on 2024/2/17.
//

import UIKit

/// UI公共模块
public class UICommonSdk {
    
    static var mBusinessImpl: ICommonBusiness?
    
    public class func initialize(businessImpl : ICommonBusiness) {
        
        UICommonSdk.mBusinessImpl = businessImpl
    }
    
    public class func onThemeChanged() {
        UICommonSdk.mBusinessImpl?.onThemeChanged()
    }
    
    /**
     * 获取返回图标
     */
    public class func getNavBackIcon() -> UIImage {
        return UICommonSdk.mBusinessImpl?.getNavBackIcon() ?? UIImage()
    }
    
    public class func getNavCancelIcon() -> UIImage {
        return UICommonSdk.mBusinessImpl?.getNavCancelIcon() ?? UIImage()
    }
    
    public class func getViewBackgroundColor() -> UIColor {
        return UICommonSdk.mBusinessImpl?.getViewBackgroundColor() ?? UIColor.clear
    }
    
    public class func getPrimaryColor() -> UIColor {
        return UICommonSdk.mBusinessImpl?.getPrimaryColor() ?? UIColor.clear
    }
    
    public class func getAccentColor() -> UIColor {
        return UICommonSdk.mBusinessImpl?.getAccentColor() ?? UIColor.clear
    }
    
    public class func getExtraColor() -> UIColor {
        return UICommonSdk.mBusinessImpl?.getExtraColor() ?? UIColor.clear
    }
    
    /**
     * 用户协议标题
     */
    public class func getUserTermsTitle() -> String {
        return UICommonSdk.mBusinessImpl?.getUserTermsTitle() ?? ""
    }
    
    /**
     获取用户协议地址
     */
    public class func getUserTermsUrl() -> String {
        return UICommonSdk.mBusinessImpl?.getUserTermsTitle() ?? ""
    }
    
    /**
     * 隐私政策标题
     */
    public class func getPrivacyTitle() -> String {
        return UICommonSdk.mBusinessImpl?.getPrivacyTitle() ?? ""
    }
    
    /**
     获取隐私政策地址
     */
    public class func getPrivacyUrl() -> String {
        return UICommonSdk.mBusinessImpl?.getPrivacyTitle() ?? ""
    }
    
    /**
     * 获取ICP
     */
    public class func getIcp() -> String {
        return UICommonSdk.mBusinessImpl?.getIcp() ?? ""
    }

    /**
     * 获取本地化
     */
    public class func getLocale() -> String {
        return UICommonSdk.mBusinessImpl?.getLocale() ?? ""
    }
    
    /**
     * 获取About title
     */
    public class func getAboutTitle() -> String {
        return UICommonSdk.mBusinessImpl?.getAboutTitle() ?? ""
    }
    
    /**
     * 获取App图标
     */
    public class func getAppIcon() -> UIImage? {
        return UICommonSdk.mBusinessImpl?.getAppIcon() ?? UIImage()
    }

    public class func getAppName() -> String {
        return UICommonSdk.mBusinessImpl?.getAppName() ?? ""
    }
    
    /**
     * 获取版本名称
     */
    public class func getVersionName() -> String {
        return UICommonSdk.mBusinessImpl?.getVersionName() ?? ""
    }
    
    
    /**
     * 获取Feedback title
     */
    public class func getFeedbackTitle() -> String {
        return UICommonSdk.mBusinessImpl?.getFeedbackTitle() ?? ""
    }
    
    public class func getFeedbackSubject() -> String {
        return UICommonSdk.mBusinessImpl?.getFeedbackSubject() ?? ""
    }
    
    public class func getFeedbackContent() -> String {
        return UICommonSdk.mBusinessImpl?.getFeedbackContent() ?? ""
    }
    
    public class func getFeedbackContact() -> String {
        return UICommonSdk.mBusinessImpl?.getFeedbackContact() ?? ""
    }
    
    public class func getSubmit() -> String {
        return UICommonSdk.mBusinessImpl?.getSubmit() ?? ""
    }
    
    /// 获取浏览器返回按钮
    /// - Returns:
    public class func getWebGobackImage() -> UIImage {
        return UICommonSdk.mBusinessImpl?.getWebGobackImage() ?? UIImage()
    }
    
    /// 获取浏览器返回选中按钮
    /// - Returns:
    public class func getWebGobackImageSelected() -> UIImage {
        return UICommonSdk.mBusinessImpl?.getWebGobackImageSelected() ?? UIImage()
    }
    
    /// 获取浏览器前向按钮
    /// - Returns:
    public class func getWebGoforwardImage() -> UIImage {
        return UICommonSdk.mBusinessImpl?.getWebGoforwardImage() ?? UIImage()
    }
    
    /// 获取浏览器前向选中按钮
    /// - Returns:
    public class func getWebGoforwardImageSelected() -> UIImage {
        return UICommonSdk.mBusinessImpl?.getWebGoforwardImageSelected() ?? UIImage()
    }
    
    public class func setKeyboardManagerAction(keyboardInputEnabled: Bool) {
        UICommonSdk.mBusinessImpl?.setKeyboardManagerAction(keyboardInputEnabled: keyboardInputEnabled)
    }
    
    public class func setAnalysisBeginPageView(clazzName: String) {
        UICommonSdk.mBusinessImpl?.setAnalysisBeginPageView(clazzName: clazzName)
    }
    
    public class func setAnalysisEndPageView(clazzName: String) {
        UICommonSdk.mBusinessImpl?.setAnalysisEndPageView(clazzName: clazzName)
    }
    
    public class func setFlashbackAction(isFlashbackEnabled: Bool) {
        UICommonSdk.mBusinessImpl?.setFlashbackAction(isFlashbackEnabled: isFlashbackEnabled)
    }
    
    public class func stopSplash() {
        UICommonSdk.mBusinessImpl?.stopSplash()
    }
    
    public class func resumeSplash() {
        UICommonSdk.mBusinessImpl?.resumeSplash()
    }
    
    public class func addFeedback(controller: UIViewController, title: String, content: String, contact: String) {
        UICommonSdk.mBusinessImpl?.addFeedback(controller: controller, title: title, content: content, contact: contact)
    }
    
    public class func showHint(_ hint: String, controller: UIViewController) {
        UICommonSdk.mBusinessImpl?.showHint(hint, controller: controller, delay: 2.0)
    }
    
}

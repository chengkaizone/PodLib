//
//  NetworkSdk.swift
//  Network
//
//  Created by tony on 2024/2/14.
//

import UIKit


public class NetworkSdk {
    

    static var mBusinessImpl: INetworkBusiness?
    
    public class func initialize(businessImpl : INetworkBusiness) {
        
        NetworkSdk.mBusinessImpl = businessImpl
    }
    
    
    /**
     * 统计分析
     */
    public class func onResumeAnalysis(_ controller: UIViewController) {
        NetworkSdk.mBusinessImpl?.onResumeAnalysis(controller)
    }
    
    /**
     * 统计分析
     *
     */
    public class func onPauseAnalysis(_ controller: UIViewController) {
        NetworkSdk.mBusinessImpl?.onPauseAnalysis(controller)
    }

    /**
     * 是否是简体中文环境
     */
    public class func isZhCN() -> Bool {
        return NetworkSdk.mBusinessImpl?.isZhCN() ?? false
    }

    /**
     * 打开用户协议
     */
    public class func startUserTerms(controller: UIViewController) {
        NetworkSdk.mBusinessImpl?.startUserTerms(controller: controller)
    }

    /**
     * 打开隐私政策
     */
    public class func startPrivacy(controller: UIViewController) {
        NetworkSdk.mBusinessImpl?.startPrivacy(controller: controller)
    }

    public class func sharedContext() -> UIApplicationDelegate {
        return NetworkSdk.mBusinessImpl!.sharedContext()
    }

    public class func isPayEnabled() -> Bool {
        return NetworkSdk.mBusinessImpl!.isPayEnabled()
    }

    public class func isEnvDev() -> Bool {
        return NetworkSdk.mBusinessImpl!.isEnvDev()
    }

    public class func getBaseUrl() -> String {
        return NetworkSdk.mBusinessImpl!.getBaseUrl()
    }

    public class func getAppCode() -> String {
        return NetworkSdk.mBusinessImpl!.getAppCode()
    }

    public class func getWxAppId() -> String {
        return NetworkSdk.mBusinessImpl!.getWxAppId()
    }

    public class func getAlipayAppId() -> String {
        return NetworkSdk.mBusinessImpl!.getAlipayAppId()
    }

    /**
     * 获取平台代码
     */
    public class func getPlatformCode() -> String {
        return NetworkSdk.mBusinessImpl!.getPlatformCode()
    }

    /**
     * 获取版本名称
     */
    public class func getVersionName() -> String {
        return NetworkSdk.mBusinessImpl!.getVersionName()
    }

    public class func getToken() -> String {
        return NetworkSdk.mBusinessImpl!.getToken()
    }

    public class func getLocale() -> String {
        return NetworkSdk.mBusinessImpl!.getLocale()
    }

    public class func dbSecretKey() -> String {
        return NetworkSdk.mBusinessImpl!.dbSecretKey()
    }

    public class func serverIV() -> String {
        return NetworkSdk.mBusinessImpl!.serverIV()
    }

    public class func cacheSecret() -> String {
        return NetworkSdk.mBusinessImpl!.cacheSecret()
    }

    public class func cacheIV() -> String {
        return NetworkSdk.mBusinessImpl!.cacheIV()
    }

    /**
     * 获取api key
     */
    public class func dbApiKey() -> String {
        return NetworkSdk.mBusinessImpl!.dbApiKey()
    }

    /**
     * 获取md5加盐
     */
    public class func md5Salt() -> String {
        return NetworkSdk.mBusinessImpl!.md5Salt()
    }

    /**
     * 是否是Google渠道
     */
    public class func isGoogleChannel() -> Bool {
        return NetworkSdk.mBusinessImpl!.isGoogleChannel()
    }

    public class func encrypt(secret: String, serverIV: String, text: String) -> String {
        return NetworkSdk.mBusinessImpl!.encrypt(secret: secret, serverIV: serverIV, text: text)
    }

    public class func decrypt(secret: String, serverIV: String, text: String) -> String {
        return NetworkSdk.mBusinessImpl!.decrypt(secret: secret, serverIV: serverIV, text: text)
    }

    public class func md5(text: String) -> String {
        return NetworkSdk.mBusinessImpl!.md5(text: text)
    }

    /**
     * 获取当前时间
     */
    public class func currentTime() -> Int64 {
        return NetworkSdk.mBusinessImpl!.currentTime()
    }

    /**
     * 获取当前时间(ms)
     */
    public class func currentTimeMillis() -> Int64 {
        return NetworkSdk.mBusinessImpl!.currentTimeMillis()
    }

    /**
     * 获取当前时间(ms)
     */
    public class func ntpServerTime() -> Int64 {
        return NetworkSdk.mBusinessImpl!.currentTimeMillis()
    }

    /**
     * 设置数据同步
     */
    public class func dataAsyncRecovery(settings : String?, calculateData : String?) {
        NetworkSdk.mBusinessImpl?.dataAsyncRecovery(settings: settings, calculateData: calculateData)
    }

    /**
     * 用户数据缓存
     */
    public class func cacheUser() {
        NetworkSdk.mBusinessImpl?.cacheUser()
    }

    /**
     * 用户数据缓存
     */
    public class func saveUser(text: String) {
        NetworkSdk.mBusinessImpl?.saveUser(text: text)
    }

    /**
     * 获取账户表数据后缀
     */
    public class func getTableSuffix() -> String {
        return NetworkSdk.mBusinessImpl?.getTableSuffix() ?? ""
    }
    
    /**
     * post请求
     */
    public class func postAFRequest(apiUrl: String, params: [String : String] = [:], _ callback: @escaping Callback<RetrofitResult>) {
        
        NetworkSdk.mBusinessImpl?.postAFRequest(apiUrl: apiUrl, params: params, callback)
    }
    
    /**
     * get请求
     */
    public class func getAFRequest(apiUrl: String, params: [String : String] = [:], _ callback: @escaping Callback<RetrofitResult>) {
        
        NetworkSdk.mBusinessImpl?.getAFRequest(apiUrl: apiUrl, params: params, callback)
    }
    
    /// get请求
    /// - Parameters:
    ///   - path:
    ///   - params:
    ///   - callback:
    public class func getAFRequest(path: String, params: [String: String] = [:], callback: @escaping Callback<String>) {
        NetworkSdk.mBusinessImpl?.getAFRequest(path: path, params: params, callback: callback)
    }
    
    
}


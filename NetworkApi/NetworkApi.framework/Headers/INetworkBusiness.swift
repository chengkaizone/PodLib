//
//  INetworkBusiness.swift
//  Network
//
//  Created by tony on 2024/2/14.
//

import UIKit

public protocol INetworkBusiness {
    
    /**
     * 统计分析
     */
    func onResumeAnalysis(_ controller: UIViewController)

    /**
     * 统计分析
     */
    func onPauseAnalysis(_ controller: UIViewController)

    /**
     * 是否是简体中文环境
     */
    func isZhCN() -> Bool

    /**
     * 打开用户协议
     */
    func startUserTerms(controller: UIViewController)

    /**
     * 打开隐私政策
     */
    func startPrivacy(controller: UIViewController)

    /**
     * 获取应用上下文
     */
    func sharedContext() -> UIApplicationDelegate

    /**
     * 是否支持支付
     */
    func isPayEnabled() -> Bool

    /**
     * 是否开发环境
     */
    func isEnvDev() -> Bool

    /**
     * 获取接口地址
     */
    func getAppCode() -> String

    /**
     * 获取微信APPID
     */
    func getWxAppId() -> String

    /**
     * 获取支付宝APPID
     */
    func getAlipayAppId() -> String

    /**
     * 获取平台代码
     */
    func getPlatformCode() -> String

    /**
     * 获取版本名称
     */
    func getVersionName() -> String

    /**
     * 获取接口地址
     */
    func getBaseUrl() -> String

    /**
     * 返回用户token
     */
    func getToken() -> String

    /**
     * 返回本地化信息
     */
    func getLocale() -> String

    /**
     * 获取当前时间
     */
    func currentTime() -> Int64

    /**
     * 获取当前时间(ms)
     */
    func currentTimeMillis() -> Int64

    /**
     * 获取网络时间
     */
    func ntpServerTime() -> Int64

    /**
     * 设置数据同步
     */
    func dataAsyncRecovery(settings : String?, calculateData : String?)

    /**
     * 用户数据缓存
     */
    func cacheUser()

    /**
     * 保存用户数据
     */
    func saveUser(text: String)

    /**
     * 获取api key
     */
    func dbApiKey() -> String

    /**
     * 获取解密密钥
     */
    func dbSecretKey() -> String

    /**
     * 获取aes加密偏移量
     */
    func serverIV() -> String

    /**
     * 获取aes加密本地缓存密钥
     */
    func cacheSecret() -> String

    /**
     * 获取aes加密本地缓存偏移量
     */
    func cacheIV() -> String

    /**
     * 获取md5加盐
     */
    func md5Salt() -> String

    /**
     * 是否是Google渠道
     */
    func isGoogleChannel() -> Bool

    /**
     * 文本编码
     */
    func encrypt(secret: String, serverIV: String, text: String) -> String

    /**
     * 密文解码
     */
    func decrypt(secret: String, serverIV: String, text: String) -> String

    /**
     * md5摘要算法
     */
    func md5(text: String) -> String

    /**
     * 获取账户表数据后缀
     */
    func getTableSuffix() -> String
    
    /**
     * post请求
     */
    func postAFRequest(apiUrl: String, params: [String : String], _ callback: @escaping Callback<RetrofitResult>)
    
    /**
     * get请求
     */
    func getAFRequest(apiUrl: String, params: [String : String], _ callback: @escaping Callback<RetrofitResult>)
    
    /// get请求
    /// - Parameters:
    ///   - path:
    ///   - params:
    ///   - callback:
    func getAFRequest(path: String, params: [String: String], callback: @escaping Callback<String>)
    
}

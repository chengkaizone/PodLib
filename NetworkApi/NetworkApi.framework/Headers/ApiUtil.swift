//
//  ApiUtil.swift
//  LineCal
//
//  Created by tony on 2023/7/9.
//  Copyright © 2023 chengkaizone. All rights reserved.
//

import Foundation

// 数据回调
public typealias Callback<T> = (T, Error?) -> Void
// http响应结果
public typealias HttpResponseResult = (HTTPURLResponse?, Result<String, Error>) -> Void

// 接口工具
public class ApiUtil {
    
    
    // 每个接口固定消息头
    public static var defHeaders = [
            "platform": "ios",
            "locale": NetworkSdk.getLocale(),
            "token": ""
    ]
    
    /// 生成接口地址
    /// - Parameter path: 接口路径
    /// - Returns:
    public class func api(_ path: String) -> String {
        return "\(NetworkSdk.getBaseUrl())/\(path)"
    }
    
    /// 获取网络时间
    /// - Parameter callback:
    public class func getTimestamp(_ callback: @escaping Callback<String>) {
        getAFRequest(path: HttpApi.TIMESTAMP, callback: callback)
    }
    
    /**
     * 查询验证码
     */
    public class func verifyRedeemCode(code: String, callback: @escaping Callback<RetrofitResult>) {
        var params = [String: String]()
        params["column"] = "*"
        params["where"] = "\(TableRedeemCode.CODE)='\(code)' and \(TableRedeemCode.STATUS)='0'"
        params["sort"] = "desc"
        params["sort_column"] = TableRedeemCode.ID
        let originalData = generateOriginalData(TableRedeemCode.TABLE_NAME, params)
        let signData = generateSignature(originalData)
        select(data: signData.0, signature: signData.1, callback: callback)
    }

    /**
     * 消费验证码
     */
    public class func consumeRedeemCode(code: String, uid: Int, callback: @escaping Callback<RetrofitResult>) {
        var params = [String: String]()
        let serverTime = currentTimeMillis()
        params["set"] = "\(TableRedeemCode.STATUS)='1',\(TableRedeemCode.UID)='\(uid)',\(TableRedeemCode.UPDATE_TIME)='\(serverTime)'"
        params["where"] = "\(TableRedeemCode.CODE)='\(code)'"
        let originalData = generateOriginalData(TableRedeemCode.TABLE_NAME, params)
        let signData = generateSignature(originalData)
        update(data: signData.0, signature: signData.1, callback: callback)
    }
    
    /**
     * 获取启用的所有商品
     */
    public class func getAllGoods(locale: String, callback: @escaping Callback<RetrofitResult>) {
        var params = [String: String]()
        params["column"] = "*"
        params["where"] = "\(TableGoods.LOCALE)='\(locale)'"
        params["sort"] = "asc"
        params["sort_column"] = TableGoods.ID
        let originalData = generateGoodsOriginalData(params)
        let signData = generateSignature(originalData)
        select(data: signData.0, signature: signData.1, callback: callback)
    }

    /**
     * 查询云数据
     */
    public class func queryCloudData(cate: String, interval: Int64, callback: @escaping Callback<RetrofitResult>) {
        let startTime = currentTimeMillis() - interval
        var params = [String: String]()
        params["column"] = "*"
        params["where"] = "\(TableCloudData.CATE)='\(cate)' and \(TableCloudData.CREATE_TIME) between \(startTime) and \(currentTimeMillis())"
        params["sort"] = "desc"
        params["sort_column"] = TableCloudData.CREATE_TIME
        
        NSLog("sql:::\(params)")
        let originalData = generateCloudDataOriginalData(params)
        let signData = generateSignature(originalData)
        select(data: signData.0, signature: signData.1, callback: callback)
    }
    
    /**
     * 保存云接口数据
     */
    public class func uploadCloudData(uid: Int, cate: String, text: String, callback: @escaping Callback<RetrofitResult>) {
        var params = [String: String]()
        let serverTime = currentTimeMillis()
        params["column"] = "`\(TableCloudData.UID)`,`\(TableCloudData.CATE)`,`\(TableCloudData.TEXT)`,`\(TableCloudData.MODEL)`,`\(TableCloudData.IPADDR)`,`\(TableCloudData.CREATE_TIME)`,`\(TableCloudData.UPDATE_TIME)`"
        params["value"] = "'\(uid)','\(cate)','\(text)','\(Build.MODEL)','\("0.0.0.0")','\(serverTime)','\(serverTime)'"
        let originalData = generateCloudDataOriginalData(params)
        let signData = generateSignature(originalData)
        insert(data: signData.0, signature: signData.1, callback: callback)
    }
    
    /**
     * 查询手机号, 没有登录，无法通过token验证
     */
    public class func queryMobile(mobile: String, callback: @escaping Callback<RetrofitResult>) {
        var params = [String: String]()
        params["column"] = TableUser.MOBILE
        params["where"] = "\(TableUser.MOBILE)='\(mobile)'"
        params["sort"] = "desc"
        params["sort_column"] = TableUser.ID
        let originalData = generateUserOriginalData(params)
        let signData = generateSignature(originalData)
        select(data: signData.0, signature: signData.1, callback: callback)
    }
    
    /**
     * 查询电子邮箱, 没有登录，无法通过token验证
     */
    public class func queryEmail(email: String, callback: @escaping Callback<RetrofitResult>) {
        var params = [String: String]()
        params["column"] = TableUser.EMAIL
        params["where"] = "\(TableUser.EMAIL)='\(email)'"
        params["sort"] = "desc"
        params["sort_column"] = TableUser.ID
        let originalData = generateUserOriginalData(params)
        let signData = generateSignature(originalData)
        select(data: signData.0, signature: signData.1, callback: callback)
    }
    
    /**
     * 用户设置是否存在
     */
    public class func queryUserSetting(uid: Int, callback: @escaping Callback<RetrofitResult>) {
        var params = [String: String]()
        params["column"] = TableUserSetting.UID
        params["where"] = "\(TableUserSetting.UID)='\(uid)'"
        params["sort"] = "desc"
        params["sort_column"] = TableUserSetting.UID
        let originalData = generateUserSettingOriginalData(params)
        let signData = generateSignature(originalData)
        select(data: signData.0, signature: signData.1, callback: callback)
    }

    /**
     * 数据同步，拉取数据
     */
    public class func dataSyncDownload(uid: Int, callback: @escaping Callback<RetrofitResult>) {
        var params = [String: String]()
        params["column"] = "`\(TableUserSetting.UID)`,`\(TableUserSetting.SETTINGS)`,`\(TableUserSetting.DATA)`"
        params["where"] = "\(TableUserSetting.UID)='\(uid)'"
        params["sort"] = "desc"
        params["sort_column"] = TableUserSetting.UID
        let originalData = generateUserSettingOriginalData(params)
        let signData = generateSignature(originalData)
        select(data: signData.0, signature: signData.1, callback: callback)
    }
    
    /**
     * 数据同步，上传数据、有用户设置数据的情况
     */
    public class func dataSyncUpload(uid: Int, settings: String, calculateData: String, callback: @escaping Callback<RetrofitResult>) {
        updateSettingInfo(uid: uid, updateContent: "\(TableUserSetting.SETTINGS)='\(settings)',\(TableUserSetting.DATA)='\(calculateData)'", callback: callback)
    }
    
    /**
     * 数据同步，上传数据、无用户设置数据的情况
     */
    public class func dataSyncInsert(uid: Int, settings: String, calculateData: String, callback: @escaping Callback<RetrofitResult>) {
        var params = [String: String]()
        let serverTime = currentTimeMillis()
        params["column"] = "`\(TableUserSetting.UID)`,`\(TableUserSetting.SETTINGS)`,`\(TableUserSetting.DATA)`,`\(TableUserSetting.CREATE_TIME)`,`\(TableUserSetting.UPDATE_TIME)`"
        params["value"] = "'\(uid)','\(settings)','\(calculateData)','\(serverTime)','\(serverTime)'"
        let originalData = generateUserSettingOriginalData(params)
        let signData = generateSignature(originalData)
        insert(data: signData.0, signature: signData.1, callback: callback)
    }
    
    /**
     * 注册账户 password
     */
    public class func register(username: String, password: String, callback: @escaping Callback<RetrofitResult>) {
        let signPwd = NetworkSdk.md5(text: NetworkSdk.md5Salt() + password)
        var paramsData = [String: Any]()
        paramsData["appcode"] = NetworkSdk.getAppCode()
        paramsData["username"] = username
        paramsData["password"] = signPwd
        paramsData["brand"] = Build.BRAND
        paramsData["model"] = Build.MODEL
        paramsData["timestamp"] = currentTime()
        NSLog("=======>>>\(paramsData)")
        let data = JSONUtil.stringForObject(paramsData as NSObject) ?? ""
        let dataCrypt = NetworkSdk.encrypt(secret: NetworkSdk.dbSecretKey(), serverIV: NetworkSdk.serverIV(), text: data)
        let signText = NetworkSdk.dbApiKey() + dataCrypt + NetworkSdk.dbSecretKey();
        let signature = NetworkSdk.md5(text: signText)
        var params = [String: String]()
        params["key"] = NetworkSdk.dbApiKey()
        params["data"] = dataCrypt
        params["signature"] = signature
        postAFRequest(apiUrl: api(HttpApi.REGISTER), params: params, callback)
    }
    
    /**
     * 用户/邮箱密码登录
     */
    public class func login(username: String, password: String, type: LoginType, callback: @escaping Callback<RetrofitResult>) {
        let signPwd = NetworkSdk.md5(text: NetworkSdk.md5Salt() + password)
        var paramsData = [String: Any]()
        paramsData["appcode"] = NetworkSdk.getAppCode()
        paramsData["type"] = type.rawValue
        paramsData["username"] = username
        paramsData["password"] = signPwd
        paramsData["timestamp"] = currentTime()
        NSLog("=======>>>\(paramsData)")
        let data = JSONUtil.stringForObject(paramsData as NSObject) ?? ""
        let dataCrypt = NetworkSdk.encrypt(secret: NetworkSdk.dbSecretKey(), serverIV: NetworkSdk.serverIV(), text: data)
        let signText = NetworkSdk.dbApiKey() + dataCrypt + NetworkSdk.dbSecretKey();
        let signature = NetworkSdk.md5(text: signText)
        var params = [String: String]()
        params["key"] = NetworkSdk.dbApiKey()
        params["data"] = dataCrypt
        params["signature"] = signature
        postAFRequest(apiUrl: api(HttpApi.LOGIN), params: params, callback)
    }
    
    /**
     * apple登录, 未注册则进行注册
     */
    public class func login(clientId: String, identityToken: String, callback: @escaping Callback<RetrofitResult>) {
        var paramsData = [String: Any]()
        paramsData["appcode"] = NetworkSdk.getAppCode()
        paramsData["type"] = LoginType.APPLE.rawValue
        paramsData["username"] = clientId
        paramsData["client_id"] = Bundle.main.bundleIdentifier
        paramsData["identity_token"] = identityToken
        paramsData["brand"] = Build.BRAND
        paramsData["model"] = Build.MODEL
        paramsData["timestamp"] = currentTime()
        NSLog("=======>>>\(paramsData)")
        let data = JSONUtil.stringForObject(paramsData as NSObject) ?? ""
        let dataCrypt = NetworkSdk.encrypt(secret: NetworkSdk.dbSecretKey(), serverIV: NetworkSdk.serverIV(), text: data)
        let signText = NetworkSdk.dbApiKey() + dataCrypt + NetworkSdk.dbSecretKey();
        let signature = NetworkSdk.md5(text: signText)
        var params = [String: String]()
        params["key"] = NetworkSdk.dbApiKey()
        params["data"] = dataCrypt
        params["signature"] = signature
        postAFRequest(apiUrl: api(HttpApi.LOGIN), params: params, callback)
    }

    /**
     * 重新加载用户数据, 使用token
     */
    public class func reloadUser(token: String, callback: @escaping Callback<RetrofitResult>) {
        var paramsData = [String: Any]()
        paramsData["appcode"] = NetworkSdk.getAppCode()
        paramsData["type"] = LoginType.TOKEN.rawValue
        paramsData["username"] = token
        paramsData["timestamp"] = currentTime()
        NSLog("=======>>>\(paramsData)")
        let data = JSONUtil.stringForObject(paramsData as NSObject) ?? ""
        let dataCrypt = NetworkSdk.encrypt(secret: NetworkSdk.dbSecretKey(), serverIV: NetworkSdk.serverIV(), text: data)
        let signText = NetworkSdk.dbApiKey() + dataCrypt + NetworkSdk.dbSecretKey();
        let signature = NetworkSdk.md5(text: signText)
        var params = [String: String]()
        params["key"] = NetworkSdk.dbApiKey()
        params["data"] = dataCrypt
        params["signature"] = signature
        postAFRequest(apiUrl: api(HttpApi.LOGIN), params: params, callback)
    }
    
    /**
     解除Apple关联
     */
    public class func opaAppleID(uid: Int, appleuser: String, callback: @escaping Callback<RetrofitResult>) {
        var params = [String: String]()
        let serverTime = currentTimeMillis()
        if appleuser == "" {
            params["set"] = "\(TableUser.APPLE_USER)=NULL,\(TableUser.UPDATE_TIME)='\(serverTime)'"
        } else {
            params["set"] = "\(TableUser.APPLE_USER)='\(appleuser)',\(TableUser.UPDATE_TIME)='\(serverTime)'"
        }
        params["where"] = "\(TableUser.ID)='\(uid)'"
        let originalData = generateUserOriginalData(params)
        let signData = generateSignature(originalData)
        update(data: signData.0, signature: signData.1, callback: callback)
    }

    /**
     * 更新订单信息
     */
    public class func updateOrder(tradeNo: String, status: Int, callback: @escaping Callback<RetrofitResult>) {
        var params = [String: String]()
        let serverTime = currentTimeMillis()
        params["set"] = "\(TableOrder.STATUS)='\(status)',\(TableOrder.UPDATE_TIME)='\(serverTime)'"
        params["where"] = "\(TableOrder.TRADE_NO)='\(tradeNo)'"
        let originalData = generateOrderOriginalData(params)
        let signData = generateSignature(originalData)
        update(data: signData.0, signature: signData.1, callback: callback)
    }

    /**
     * 生成订单号
     */
    public class func createOrder(uid: Int, payType: String, goodsId: Int, tradeNo: String, content: String, callback: @escaping Callback<RetrofitResult>) {
        var params = [String: String]()
        let serverTime = currentTimeMillis()
        params["column"] = "`\(TableOrder.UID)`,`\(TableOrder.PAY_TYPE)`,`\(TableOrder.PLATFORM_TYPE)`,`\(TableOrder.TRADE_NO)`,`\(TableOrder.GOODS_ID)`,`\(TableOrder.CONTENT)`,`\(TableOrder.BRAND)`,`\(TableOrder.MODEL)`,`\(TableOrder.VERSION)`,`\(TableOrder.CREATE_TIME)`,`\(TableOrder.UPDATE_TIME)`"
        params["value"] = "'\(uid)','\(payType)','\(Platform.iOS.getCode())','\(tradeNo)','\(goodsId)','\(content)','\(Build.BRAND)','\(Build.MODEL)','\(NetworkSdk.getVersionName())','\(serverTime)','\(serverTime)'"
        let originalData = generateOrderOriginalData(params)
        let signData = generateSignature(originalData)
        insert(data: signData.0, signature: signData.1, callback: callback)
    }

    /**
     * 验证Apple
     */
    public class func checkApple(uid: Int, appleuser: String, callback: @escaping Callback<RetrofitResult>) {
        var params = [String: String]()
        params["column"] = "*"
        params["where"] = "\(TableUser.ID)='\(uid)' and \(TableUser.APPLE_USER)='\(appleuser)'"
        params["sort"] = "desc"
        params["sort_column"] = TableUser.ID
        let originalData = generateUserOriginalData(params)
        let signData = generateSignature(originalData)
        select(data: signData.0, signature: signData.1, callback: callback)
    }
    
    /**
     * 验证密码
     */
    public class func checkPassword(uid: Int, password: String, callback: @escaping Callback<RetrofitResult>) {
        let signPwd = NetworkSdk.md5(text: NetworkSdk.md5Salt() + password)
        var params = [String: String]()
        params["column"] = "*"
        params["where"] = "\(TableUser.ID)='\(uid)' and \(TableUser.PASSWORD)='\(signPwd)'"
        params["sort"] = "desc"
        params["sort_column"] = TableUser.ID
        let originalData = generateUserOriginalData(params)
        let signData = generateSignature(originalData)
        select(data: signData.0, signature: signData.1, callback: callback)
    }

    /**
     * 通过手机号更新密码
     */
    public class func updatePasswordForMobile(mobile: String, password: String, callback: @escaping Callback<RetrofitResult>) {
        let signPwd = NetworkSdk.md5(text: NetworkSdk.md5Salt() + password)
        updateInfoForMobile(mobile: mobile, updateContent: "\(TableUser.PASSWORD)='\(signPwd)'", callback: callback)
    }
    
    /**
     * 通过邮箱更新密码
     */
    public class func updatePasswordForEmail(email: String, password: String, callback: @escaping Callback<RetrofitResult>) {
        let signPwd = NetworkSdk.md5(text: NetworkSdk.md5Salt() + password)
        updateInfoForEmail(email: email, updateContent: "\(TableUser.PASSWORD)='\(signPwd)'", callback: callback)
    }

    /**
     * 更新绑定Apple ID
     */
    public class func updateAppleUser(uid: Int, appleUserId: String, callback: @escaping Callback<RetrofitResult>) {
        updateInfo(uid: uid, updateContent: "\(TableUser.APPLE_USER)='\(appleUserId)'", callback: callback)
    }
    
    /**
     * 更新密码
     */
    public class func updatePassword(uid: Int, password: String, callback: @escaping Callback<RetrofitResult>) {
        let signPwd = NetworkSdk.md5(text: NetworkSdk.md5Salt() + password)
        updateInfo(uid: uid, updateContent: "\(TableUser.PASSWORD)='\(signPwd)'", callback: callback)
    }

    /**
     * 更新手机号
     */
    public class func updateMobile(uid: Int, mobile: String, callback: @escaping Callback<RetrofitResult>) {
        updateInfo(uid: uid, updateContent: "\(TableUser.MOBILE)='\(mobile)'", callback: callback)
    }

    /**
     * 更新邮箱
     */
    public class func updateEmail(uid: Int, email: String, callback: @escaping Callback<RetrofitResult>) {
        updateInfo(uid: uid, updateContent: "\(TableUser.EMAIL)='\(email)'", callback: callback)
    }

    /**
     * 更新用户名
     */
    public class func updateUsername(uid: Int, username: String, callback: @escaping Callback<RetrofitResult>) {
        let serverTime = currentTimeMillis()
        updateInfo(uid: uid, updateContent: "\(TableUser.USERNAME)='\(username)',\(TableUser.MODN_TIME)='\(serverTime)'", callback: callback)
    }

    /**
     * 更新昵称
     */
    public class func updateNickname(uid: Int, nickname: String, callback: @escaping Callback<RetrofitResult>) {
        updateInfo(uid: uid, updateContent: "\(TableUser.NICKNAME)='\(nickname)'", callback: callback)
    }

    /**
     * 更新头像
     */
    public class func updateAvatar(uid: Int, avatar: String, callback: @escaping Callback<RetrofitResult>) {
        updateInfo(uid: uid, updateContent: "\(TableUser.AVATAR)='\(avatar)'", callback: callback)
    }

    /**
     * 更新性别
     */
    public class func updateSex(uid: Int, sex: Int, callback: @escaping Callback<RetrofitResult>) {
        updateInfo(uid: uid, updateContent: "\(TableUser.SEX)='\(sex)'", callback: callback)
    }

    /**
     * 更新永久会员
     */
    public class func updateVipForever(uid: Int, vipforever: Int, callback: @escaping Callback<RetrofitResult>) {
        updateInfo(uid: uid, updateContent: "\(TableUser.VIP_FOREVER)='\(vipforever)'", callback: callback)
    }
    
    /**
     * 更新免广告
     */
    public class func updateAdFree(uid: Int, adFree: Int, callback: @escaping Callback<RetrofitResult>) {
        updateInfo(uid: uid, updateContent: "\(TableUser.AD_FREE)='\(adFree)'", callback: callback)
    }

    /**
     * 更新会员时间
     */
    public class func updateExpireTime(uid: Int, expiretime: Int64, callback: @escaping Callback<RetrofitResult>) {
        updateInfo(uid: uid, updateContent: "\(TableUser.EXPIRE_TIME)='\(expiretime)'", callback: callback)
    }

    /**
     * 更新用户信息
     */
    public class func updateInfoForMobile(mobile: String, updateContent: String, callback: @escaping Callback<RetrofitResult>) {
        var params = [String: String]()
        params["set"] = updateContent
        params["where"] = "\(TableUser.MOBILE)='\(mobile)'"
        let originalData = generateUserOriginalData(params)
        let signData = generateSignature(originalData)
        update(data: signData.0, signature: signData.1, callback: callback)
    }
    
    /**
     * 更新用户信息
     */
    public class func updateInfoForEmail(email: String, updateContent: String, callback: @escaping Callback<RetrofitResult>) {
        var params = [String: String]()
        params["set"] = updateContent
        params["where"] = "\(TableUser.EMAIL)='\(email)'"
        let originalData = generateUserOriginalData(params)
        let signData = generateSignature(originalData)
        update(data: signData.0, signature: signData.1, callback: callback)
    }

    /**
     * 更新用户信息
     */
    public class func updateSettingInfo(uid: Int, updateContent: String, callback: @escaping Callback<RetrofitResult>) {
        var params = [String: String]()
        params["set"] = updateContent
        params["where"] = "\(TableUserSetting.UID)='\(uid)'"
        let originalData = generateUserSettingOriginalData(params)
        let signData = generateSignature(originalData)
        update(data: signData.0, signature: signData.1, callback: callback)
    }
    
    /**
     * 更新用户信息
     */
    public class func updateInfo(uid: Int, updateContent: String, callback: @escaping Callback<RetrofitResult>) {
        var params = [String: String]()
        params["set"] = updateContent
        params["where"] = "\(TableUser.ID)='\(uid)'"
        let originalData = generateUserOriginalData(params)
        let signData = generateSignature(originalData)
        update(data: signData.0, signature: signData.1, callback: callback)
    }

    /**
     * 注销账户
     */
    public class func deleteUser(userId: Int, callback: @escaping Callback<RetrofitResult>) {
        var params = [String: String]()
        params["where"] = "\(TableUser.ID)=\(userId)"
        let originalData = generateUserOriginalData(params)
        let signData = generateSignature(originalData)
        delete(data: signData.0, signature: signData.1, callback: callback)
    }
    
    /**
     *  反馈建议
     */
    public class func addFeedback(uid: Int, title: String, content: String, contact: String, callback: @escaping Callback<RetrofitResult>) {
        var params = [String: String]()
        let serverTime = currentTimeMillis()
        params["column"] = "`\(TableFeedback.UID)`,`\(TableFeedback.TITLE)`,`\(TableFeedback.CONTENT)`,`\(TableFeedback.CONTACT)`,`\(TableFeedback.IPADDR)`,`\(TableFeedback.BRAND)`,`\(TableFeedback.MODEL)`,`\(TableFeedback.CREATE_TIME)`,`\(TableFeedback.UPDATE_TIME)`"
        params["value"] = "'\(uid)','\(title)','\(content)','\(contact)','0.0.0.0','\(Build.BRAND)','\(Build.MODEL)','\(serverTime)','\(serverTime)'"
        let originalData = generateOriginalData(TableFeedback.TABLE_NAME, params)
        let signData = generateSignature(originalData)
        insert(data: signData.0, signature: signData.1, callback: callback)
    }

    /// 插入数据
    /// - Parameters:
    ///   - key:
    ///   - data:
    ///   - signature:
    ///   - callback:
    public class func insert(data: String, signature: String, callback: @escaping Callback<RetrofitResult>) {
        postRequest(path: HttpApi.INSERT, data: data, signature: signature, callback: callback)
    }
    
    /// 删除数据
    /// - Parameters:
    ///   - key:
    ///   - data:
    ///   - signature:
    ///   - callback:
    public class func delete(data: String, signature: String, callback: @escaping Callback<RetrofitResult>) {
        postRequest(path: HttpApi.DELETE, data: data, signature: signature, callback: callback)
    }
    
    /// 更新数据
    /// - Parameters:
    ///   - key:
    ///   - data:
    ///   - signature:
    ///   - callback:
    public class func update(data: String, signature: String, callback: @escaping Callback<RetrofitResult>) {
        postRequest(path: HttpApi.UPDATE, data: data, signature: signature, callback: callback)
    }
    
    /// 查询数据
    /// - Parameters:
    ///   - key:
    ///   - data:
    ///   - signature:
    ///   - callback:
    public class func select(data: String, signature: String, callback: @escaping Callback<RetrofitResult>) {
        postRequest(path: HttpApi.SELECT, data: data, signature: signature, callback: callback)
    }
    
    
    /// 请求通用接口
    /// - Parameters:
    ///   - path:
    ///   - data:
    ///   - signature:
    ///   - callback:
    public class func postRequest(path: String, data: String, signature: String, callback: @escaping Callback<RetrofitResult>) {
        var params = [String: String]()
        params["key"] = NetworkSdk.dbApiKey()
        params["data"] = data
        params["signature"] = signature
        postAFRequest(apiUrl: api(path), params: params, callback)
    }
    
    /// sql命令
    /// - Parameters:
    ///   - key:
    ///   - data:
    ///   - signature:
    ///   - callback:
    public class func command(key: String, data: String, signature: String, callback: @escaping Callback<RetrofitResult>) {
        postAFRequest(apiUrl: api(HttpApi.COMMAND), callback)
    }

    /**
     * 生成加密文本和签名
     */
    private class func generateSignature(_ data: String) -> (String, String) {
        let dataCrypt = NetworkSdk.encrypt(secret: NetworkSdk.dbSecretKey(), serverIV: NetworkSdk.serverIV(), text: data)
        let signText = NetworkSdk.dbApiKey() + dataCrypt + NetworkSdk.dbSecretKey();
        let signature = NetworkSdk.md5(text: signText)
        return (dataCrypt, signature)
    }

    /**
     * 生成订单表原始数据
     */
    private class func generateOrderOriginalData(_ params: [String: String]) -> String {
        return generateOriginalData(TableOrder.TABLE_NAME, params)
    }

    /**
     * 生成User设置表原始数据
     */
    private class func generateUserSettingOriginalData(_ params: [String: String]) -> String {
        return generateOriginalData(TableUserSetting.TABLE_NAME, params)
    }
    
    /**
     * 生成User表原始数据
     */
    private class func generateUserOriginalData(_ params: [String: String]) -> String {
        return generateOriginalData(TableUser.TABLE_NAME, params)
    }

    /**
     * 生成商品表原始数据
     */
    private class func generateGoodsOriginalData(_ params: [String: String]) -> String {
        return generateOriginalData(TableGoods.TABLE_NAME, params)
    }
    
    /**
     * 生成云数据表原始数据
     */
    private class func generateCloudDataOriginalData(_ params: [String: String]) -> String {
        return generateOriginalData(TableCloudData.TABLE_NAME, params)
    }

    /**
     * 生成data数据
     */
    private class func generateOriginalData(_ table: String, _ params: [String: String]) -> String {
        var dataObject = [String: Any]()
        dataObject["table"] = table
        dataObject["timestamp"] = currentTime()
        for (key, value) in params {
            dataObject[key] = value
        }
        return JSONUtil.stringForObject(dataObject as NSObject) ?? ""
    }
    
    /**
     * 发送验证码
     */
    public class func cloudSelect(cate: String, callback: @escaping Callback<RetrofitResult>) {
        var paramsData = [String: Any]()
        paramsData["cate"] = cate
        paramsData["timestamp"] = currentTime()
        let data = JSONUtil.stringForObject(paramsData as NSObject) ?? ""
        let dataCrypt = NetworkSdk.encrypt(secret: NetworkSdk.dbSecretKey(), serverIV: NetworkSdk.serverIV(), text: data)
        let signText = NetworkSdk.dbApiKey() + dataCrypt + NetworkSdk.dbSecretKey();
        let signature = NetworkSdk.md5(text: signText)
        var params = [String: String]()
        params["key"] = NetworkSdk.dbApiKey()
        params["data"] = dataCrypt
        params["signature"] = signature
        postAFRequest(apiUrl: api(HttpApi.CLOUD_SELECT), params: params, callback)
    }

    /**
     * 验证短信
     */
    public class func cloudAdd(uid: Int, cate: String, text: String, callback: @escaping Callback<RetrofitResult>) {
        var paramsData = [String: Any]()
        paramsData["uid"] = uid
        paramsData["cate"] = cate
        paramsData["text"] = text
        paramsData["model"] = "\(Build.BRAND)_\(Build.MODEL)"
        paramsData["ipaddr"] = "0.0.0.0"
        paramsData["timestamp"] = currentTime()
        let data = JSONUtil.stringForObject(paramsData as NSObject) ?? ""
        let dataCrypt = NetworkSdk.encrypt(secret: NetworkSdk.dbSecretKey(), serverIV: NetworkSdk.serverIV(), text: data)
        let signText = NetworkSdk.dbApiKey() + dataCrypt + NetworkSdk.dbSecretKey();
        let signature = NetworkSdk.md5(text: signText)
        var params = [String: String]()
        params["key"] = NetworkSdk.dbApiKey()
        params["data"] = dataCrypt
        params["signature"] = signature
        postAFRequest(apiUrl: api(HttpApi.CLOUD_ADD), params: params, callback)
    }

    /**
     * 发送验证码
     */
    public class func sendVerifyCode(type: Int, target: String, callback: @escaping Callback<RetrofitResult>) {
        var paramsData = [String: Any]()
        paramsData["appcode"] = NetworkSdk.getAppCode()
        paramsData["type"] = type
        paramsData["target"] = target
        paramsData["timestamp"] = currentTime()
        let data = JSONUtil.stringForObject(paramsData as NSObject) ?? ""
        let dataCrypt = NetworkSdk.encrypt(secret: NetworkSdk.dbSecretKey(), serverIV: NetworkSdk.serverIV(), text: data)
        let signText = NetworkSdk.dbApiKey() + dataCrypt + NetworkSdk.dbSecretKey();
        let signature = NetworkSdk.md5(text: signText)
        var params = [String: String]()
        params["key"] = NetworkSdk.dbApiKey()
        params["data"] = dataCrypt
        params["signature"] = signature
        postAFRequest(apiUrl: api(HttpApi.SEND_VERIFY_CODE), params: params, callback)
    }

    /**
     * 验证短信
     */
    public class func codeVerify(type: Int, target: String, code: String, password: String, callback: @escaping Callback<RetrofitResult>) {
        let signPwd = NetworkSdk.md5(text: NetworkSdk.md5Salt() + password)
        var paramsData = [String: Any]()
        paramsData["appcode"] = NetworkSdk.getAppCode()
        paramsData["code"] = code
        paramsData["target"] = target
        paramsData["password"] = signPwd
        paramsData["type"] = type
        paramsData["timestamp"] = currentTime()
        let data = JSONUtil.stringForObject(paramsData as NSObject) ?? ""
        let dataCrypt = NetworkSdk.encrypt(secret: NetworkSdk.dbSecretKey(), serverIV: NetworkSdk.serverIV(), text: data)
        let signText = NetworkSdk.dbApiKey() + dataCrypt + NetworkSdk.dbSecretKey();
        let signature = NetworkSdk.md5(text: signText)
        var params = [String: String]()
        params["key"] = NetworkSdk.dbApiKey()
        params["data"] = dataCrypt
        params["signature"] = signature
        postAFRequest(apiUrl: api(HttpApi.VERIFY_CODE_VERIFY), params: params, callback)
    }

    /**
     * 获取当前时间（s）
     */
    public class func currentTime() -> Int64 {
        return NetworkSdk.currentTime()
    }

    /**
     * 获取当前时间（ms）
     */
    public class func currentTimeMillis() -> Int64 {
        return NetworkSdk.currentTimeMillis()
    }
    
    /// 请求接口回调
    /// - Parameter callback:
    /// - Returns:
    public class func requestCompleteFunc(_ callback: @escaping Callback<RetrofitResult>) -> HttpResponseResult {
        return requestCompleteFunc(NetworkSdk.dbSecretKey(), callback)
    }
    
    /// 请求接口回调
    /// - Parameter callback:
    /// - Returns:
    public class func requestAccountCompleteFunc(_ callback: @escaping Callback<RetrofitResult>) -> HttpResponseResult {
        return requestCompleteFunc(NetworkSdk.dbSecretKey(), callback)
    }
    
    /// 请求接口回调
    /// - Parameter callback:
    /// - Returns:
    private class func requestCompleteFunc(_ secret: String , _ callback: @escaping Callback<RetrofitResult>) -> HttpResponseResult {

        let requestComplete: HttpResponseResult = { response, resultResp in

            if let response = response {
                for (field, value) in response.allHeaderFields {
                    var headers = [String: String]()
                    headers["\(field)"] = "\(value)"
                    // 响应头
                    //NSLog("resp headers \(headers)")
                }
            }

            switch resultResp {
            case let .success(result):
                let text = NetworkSdk.decrypt(secret: secret, serverIV: NetworkSdk.serverIV(), text: result)
                
                NSLog("===>> original text::\(text)")
                let dict = JSONUtil.dictionaryFromJSON(jsonString: text)
                let code = (dict["code"] as? Int) ?? 1
                let status = (dict["status"] as? Int) ?? 0
                let msg = (dict["msg"] as? String) ?? ""
                var data: Any? = nil
                if let dataDict = dict["data"] as? [String: Any],
                    let dataArr = dataDict["data"] as? [Any], dataArr.count > 0 {
                    data = dataArr
                } else if let dataArr = dict["data"] as? [Any], dataArr.count > 0 {
                    data = dataArr
                } else if let dataStr = dict["data"] as? String, !dataStr.isEmpty {
                    data = dataStr
                }
                
                callback(RetrofitResult(code: code, msg: msg, data: data, status: status), nil)
                break
            case let .failure(error):
                callback(RetrofitResult(code: 1, msg: "\(error.localizedDescription)", data: nil, status: 0), error)
                break
            }
        }
        return requestComplete
    }
    
    /// 请求接口回调
    /// - Parameter callback:
    /// - Returns:
    public class func requestCompleteFuncString(_ callback: @escaping Callback<String>) -> HttpResponseResult {

        let requestComplete: HttpResponseResult = { response, resultResp in

            if let response = response {
                for (field, value) in response.allHeaderFields {
                    var headers = [String: String]()
                    headers["\(field)"] = "\(value)"
                    // 响应头
                    //NSLog("resp headers \(headers)")
                }
            }

            switch resultResp {
            case let .success(result):
                callback(result, nil)
                break
            case let .failure(error):
                callback("", error)
                break
            }
        }
        return requestComplete
    }
    
    /**
     * post请求
     */
    private class func postAFRequest(apiUrl: String, params: [String : String] = [:], _ callback: @escaping Callback<RetrofitResult>) {
        
        NetworkSdk.postAFRequest(apiUrl: apiUrl, params: params, callback)
    }
    
    /**
     * get请求
     */
    private class func getAFRequest(apiUrl: String, params: [String : String] = [:], _ callback: @escaping Callback<RetrofitResult>) {
        NetworkSdk.getAFRequest(apiUrl: apiUrl, params: params, callback)
    }
    
    /// get请求
    /// - Parameters:
    ///   - path:
    ///   - params:
    ///   - callback:
    private class func getAFRequest(path: String, params: [String: String] = [:], callback: @escaping Callback<String>) {
        NetworkSdk.getAFRequest(path: path, params: params, callback: callback)
    }
    
}

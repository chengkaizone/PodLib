//
//  RetrofitResult.swift
//  LineCal
//
//  Created by tony on 2023/6/14.
//  Copyright © 2023 chengkaizone. All rights reserved.
//

import Foundation

/**
 * 网络服务访问结果
 */
public class RetrofitResult {
    
    public var code: Int
    public var msg: String
    // 解析时定位到了数据部分，过滤掉了第一层data
    public var data: Any?
    // 用于接收错误码
    public var status: Int
    
    convenience init() {
        self.init(code: 0, msg: "", status: 0)
    }
    
    init(code: Int, msg: String, data: Any? = nil, status: Int) {
        self.code = code
        self.msg = msg
        self.data = data
        self.status = status
    }
    
    /**
     * 是否请求成功
     */
    public func isSuccess() -> Bool {
        return code == 1
    }
    
    /**
     * 是否服务器错误, 无法连接数据库
     */
    public func isServerError() -> Bool {
        if msg == "" {
            return false
        }
        return msg.lowercased().hasPrefix("fail to connect database")
    }

    /**
     * 是否重复
     */
    public func isDuplicate() -> Bool {
        if msg == "" {
            return false
        }
        return msg.lowercased().contains("duplicate")
    }
    
    public func toString() -> String {
        return "\(code) \(msg) \(String(describing: data))"
    }
    
}

extension RetrofitResult {
    
    
    /**
     * 解析云数据
     */
    public func preparedCloudData() -> CloudData? {
        guard let data = data as? [[String : Any]], data.count > 0 else {
            return nil
        }
        return CloudData(data: data[0])
    }    
    
    /// 解析验证码
    /// - Returns:
    public func preparedRedeemCode() -> RedeemCode? {
        guard let data = data as? [[String : Any]], data.count > 0 else {
            return nil
        }
        return RedeemCode(data: data[0])
    }
    
    /**
     * 解析uid
     */
    public func preparedUid() -> Int {
        guard let data = data as? [[String : Any]], data.count > 0 else {
            return 0
        }
        return data[0]["uid"] as? Int ?? 0
    }
    
    /**
     * 解析手机号
     */
    public func preparedMobile() -> String? {
        guard let data = data as? [[String : Any]], data.count > 0 else {
            return nil
        }
        return data[0]["mobile"] as? String
    }
    
    /**
     * 解析邮件地址
     */
    public func preparedEmail() -> String? {
        guard let data = data as? [[String : Any]], data.count > 0 else {
            return nil
        }
        return data[0]["email"] as? String
    }
    
    /**
     * 解析设置
     */
    public func preparedSettings() -> String? {
        guard let data = data as? [[String : Any]], data.count > 0 else {
            return nil
        }
        return data[0]["settings"] as? String
    }

    /**
     * 解析用户设置数据
     */
    public func preparedCalculateData() -> String? {
        guard let data = data as? [[String : Any]], data.count > 0 else {
            return nil
        }
        return data[0]["data"] as? String
    }

    /**
     * 解析验证码过期时间
     */
    public func preparedVerifyExpireTime() -> Int64 {
        guard let data = data as? [[String : Any]], data.count > 0 else {
            return 0
        }
        return data[0]["expire_time"] as? Int64 ?? 0
    }

    /**
     * 解析验证码过期剩余时间
     */
    public func preparedVerifyInterval() -> Int64 {
        guard let data = data as? [[String : Any]], data.count > 0 else {
            return 0
        }
        return data[0]["remain_interval"] as? Int64 ?? 0
    }
    
}

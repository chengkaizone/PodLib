//
//  RedeemCode.swift
//  LineCal
//
//  Created by tony on 2023/7/29.
//  Copyright © 2023 chengkaizone. All rights reserved.
//

import Foundation


/// 兑换码
public class RedeemCode {
    
    public var id: Int = 0
    public var code: String
    public var type: Int = 0
    public var amount: Int64 = 0
    public var describe: String
    public var status: Int = 0
    public var uid: Int = 0
    public var createTime: Int64 = 0
    public var updateTime: Int64 = 0
    
    init(id: Int, code: String, type: Int, amount: Int64, describe: String, status: Int, uid: Int, createTime: Int64, updateTime: Int64) {
        self.id = id
        self.code = code
        self.type = type
        self.amount = amount
        self.describe = describe
        self.status = status
        self.uid = uid
        self.createTime = createTime
        self.updateTime = updateTime
    }
    
    convenience init() {
        self.init(id: 0, code: "", type: 0, amount: 0, describe: "", status: 0, uid: 0, createTime: 0, updateTime: 0)
    }
    
    /// 字典初始化用户数据
    /// - Parameter userdata:
    init(data: [String: Any]) {
        if let id = data["id"] as? Int {
            self.id = id
        }
        self.code = data["code"] as? String ?? ""
        self.describe = data["describe"] as? String ?? ""
        if let type = data["type"] as? Int {
            self.type = type
        }
        if let amount = data["amount"] as? Int64 {
            self.amount = amount
        }
        if let status = data["status"] as? Int {
            self.status = status
        }
        if let uid = data["status"] as? Int {
            self.uid = uid
        }
        if let createTime = data["create_time"] as? Int64 {
            self.createTime = createTime
        }
        if let updateTime = data["update_time"] as? Int64 {
            self.updateTime = updateTime
        }
    }
    
    func toString() -> String {
        return "\(id) \(code) \(type) \(amount) \(describe) \(status) \(createTime) \(updateTime)"
    }
    
}

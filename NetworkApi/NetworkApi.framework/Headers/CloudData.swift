//
//  CloudData.swift
//  LineCal
//
//  Created by tony on 2023/10/21.
//  Copyright © 2023 chengkaizone. All rights reserved.
//

import Foundation


/// 云市场数据
public class CloudData {
    
    public var id: Int = 0
    public var uid: Int = 0
    public var cate: String = ""
    public var text: String
    public var model: String
    public var ipaddr: String
    public var createTime: Int64 = 0
    public var updateTime: Int64 = 0
    
    convenience init() {
        self.init(id: 0, uid: 0, cate: "", text: "", model: "", ipaddr: "")
    }
    
    init(id: Int, uid: Int, cate: String, text: String, model: String, ipaddr: String) {
        self.id = id
        self.uid = uid
        self.cate = cate
        self.text = text
        self.model = model
        self.ipaddr = ipaddr
        self.createTime = Int64(Date().timeIntervalSince1970 * 1000)
        self.updateTime = createTime
    }
    
    /// 字典初始化用户数据
    /// - Parameter data:
    init(data: [String: Any]) {
        if let id = data["id"] as? Int {
            self.id = id
        }
        if let uid = data["uid"] as? Int {
            self.uid = uid
        }
        self.cate = data["cate"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
        self.model = data["model"] as? String ?? ""
        self.ipaddr = data["ipaddr"] as? String ?? ""
        if let createTime = data["create_time"] as? Int64 {
            self.createTime = createTime
        }
        if let updateTime = data["update_time"] as? Int64 {
            self.updateTime = updateTime
        }
    }
    
    func toDictionary() -> [String: String] {
        var dict = [String : String]()
        dict["uid"] = "\(uid)"
        dict["cate"] = cate
        dict["text"] = text
        dict["model"] = model
        dict["ipaddr"] = "\(ipaddr)"
        dict["create_time"] = "\(createTime)"
        dict["update_time"] = "\(updateTime)"
        return dict
    }
    
    func toJson() -> String {
        return jsonSerialization(dict: toDictionary())
    }
    
    func toString() -> String {
        return toJson()
    }
    
    
    /// 转化为json字符串序列
    func jsonSerialization(dict: Dictionary<String, Any>) ->String {
        
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
            let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            let result = str?.replacingOccurrences(of: "\n", with: "")
            return result!
        } catch let error {
            NSLog("error: \(error.localizedDescription)")
        }
        
        return ""
    }
    
    
}

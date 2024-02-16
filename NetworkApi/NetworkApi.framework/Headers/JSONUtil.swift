//
//  JSONUtil.swift
//  Network
//
//  Created by tony on 2024/2/14.
//

import Foundation

class JSONUtil {
    
    /// 转化json对象为字符串 可将字典转为JSON
    class func stringForObject(_ jsonObj: Any) -> String? {
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObj, options: JSONSerialization.WritingOptions.prettyPrinted);
            
            if jsonData.count > 0 {
                var reqStr = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
                
                reqStr = reqStr?.replacingOccurrences(of: "\n", with: "") as NSString?
                return reqStr as String?
            }
        } catch let error as NSError {
            NSLog("json parse error: \(error.description)")
        }
        
        return nil
    }
    
    /// JSON转为字典
    class func dictionaryFromJSON(jsonString: String) -> NSDictionary {
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            return NSDictionary()
        }
        guard let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) else {
            return NSDictionary()
        }
        return dict as! NSDictionary
    }
    
}

//
//  LYEmoticonKeyboardManager.swift
//  LineVideo
//
//  Created by tony on 16/3/7.
//  Copyright © 2016年 chengkaizone. All rights reserved.
//

import UIKit

public class LYEmoticonKeyboardManager: NSObject {
    
    /// 加载内置表情 --- 多种
    public class func loadPreloadEmoticons() ->[LYEmoticonPackage]? {
        let bundlePath = Bundle.main.path(forResource: "Emoticon", ofType: "bundle")! as NSString
        let emoticonPath = bundlePath.appendingPathComponent("emoticon.plist")
        
        guard let emoticonDict = NSDictionary(contentsOfFile: emoticonPath) else {
            return nil
        }
        var packages = [LYEmoticonPackage]()
        /// 获取表情包数组
        let packageArr = emoticonDict["package"] as! [[String: AnyObject]]
        
        for dict in packageArr {
            
            let id = dict["id"] as! String
            
            let package = LYEmoticonPackage(id: id, directory: nil, bundleName: "Emoticon", type: 0)
            packages.append(package)
        }
        
        return packages
    }
    
}

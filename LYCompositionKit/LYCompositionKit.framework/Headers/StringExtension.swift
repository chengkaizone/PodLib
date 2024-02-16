//
//  String+Path.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit

extension String {
    
    func withNonZeroSuffix(_ suffix:Int) -> String {
        if suffix == 0 {
            return self
        } else {
            return "\(self)\(suffix + 1)"
        }
    }
    
    /**
     * String转为GLchar类型指针
     */
    func withGLChar(_ operation:(UnsafePointer<GLchar>) -> ()) {
        if let value = self.cString(using:String.Encoding.utf8) {
            operation(UnsafePointer<GLchar>(value))
        } else {
            fatalError("Could not convert this string to UTF8: \(self)")
        }
    }
    
    /**
     * 计算相对doc目录的路径
     * 用于处理保存绝对路径的情况,或者多级路径的情况
     */
    func relativeDocPath() ->String {
        let docDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString;
        let path:NSString = self as NSString;
        
        var relativePath = self;
        let range = path.range(of: "Documents/", options: .literal);// 区分大小写
        
        if range.location != NSNotFound {
            relativePath = path.substring(from: range.location + range.length);
        }
        
        let filePath = docDir.appendingPathComponent(relativePath);
        
        return filePath;
    }
    
    /**
     *  获取相对的app路径
     *  用于处理保存绝对路径的情况
     */
    func relativeAppPath() ->String {
        
        let bundlePath = Bundle.main.bundlePath as NSString;
        let appDir = NSString(format: "%@/", bundlePath.lastPathComponent);
        
        let path:NSString = self as NSString;
        
        let range = path.range(of: appDir as String, options: .literal);
        
        
        var relativePath = self;
        if range.location != NSNotFound {
            relativePath = path.substring(from: range.location + range.length);
        }
        
        let filePath = bundlePath.appendingPathComponent(relativePath);
        
        return filePath;
    }
    
}


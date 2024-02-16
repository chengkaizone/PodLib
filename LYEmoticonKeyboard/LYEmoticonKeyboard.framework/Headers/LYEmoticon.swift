//
//  LYEmoticon.swift
//  LYEmoticonKeyboard
//
//  Created by tony on 16/2/24.
//  Copyright © 2016年 tony. All rights reserved.
//

import UIKit

/// 表情数据模型
open class LYEmoticon: NSObject {
    
    /// 表情标识(平台唯一)---也作为内置表情包的对应文件夹
    open var id: String
    
    /// 表情路径类型 -1:表示键盘表情 0:内置, 1:沙盒路径 default = 0
    open var locationType: Int = 0
    
    /// 文件显示名
    open var name: String?
    
    /// 对应的文件名 --- 包含后缀
    open var gif: String!
    
    /// 静态图片文件名 一律使用png格式
    open var png: String!
    
    /// 表情对应的包资源
    open var bundleName: String?
    
    /// 作为沙盒路径下doc的表情主目录---表情标识为包目录
    open var fileDirectory: String?
    
    /// 表情类型 0:静态表情 1:gif动态表情 default = 0
    open var type: Int = 0
    
    /// 展示尺寸
    open var size: CGSize
    
    /// 预览尺寸
    open var previewSize: CGSize
    
    /// 计算出表情的完整路径
    open var path: String? {
        get {
            switch locationType {
            case -1:// 不处理
                break
            case 0:
                var bundlePath: String? = Bundle.main.bundlePath
                if bundleName != nil {
                    bundlePath = Bundle.main.path(forResource: bundleName, ofType: "bundle")
                }
                if bundlePath == nil {
                    return nil
                }
                
                let filename = self.type == 0 ? png : gif
                
                let path = (bundlePath! + "/\(id)" as NSString).appendingPathComponent(filename!)
                return path
            case 1:
                guard let directory = fileDirectory else {
                    return nil
                }
                
                var paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true);
                let doc = paths[0] as String
                
                let filename = self.type == 0 ? png : gif
                let path = (doc + "/\(directory)/\(id)" as NSString).appendingPathComponent(filename!)
                return path
            default:
                break
            }
            
            return nil
        }
    }
    
    //MARK: 初始化构造器
    init(id: String, name: String?, png: String!, gif: String!, fileDirectory: String?, bundleName: String?, locationType: Int, type: Int) {
        self.id = id
        self.name = name
        self.png = png
        self.gif = gif
        self.fileDirectory = fileDirectory
        self.bundleName = bundleName
        self.locationType = locationType
        self.type = type
        
        self.size = CGSize.zero
        self.previewSize = CGSize.zero
        
        super.init()
    }
    
    // ========================系统内置表情不考虑===============================
    /// emoji的16进制字符串 遵循unicode编码
    open var code: String? {
        didSet {// 考虑到效率,直接在这里计算,避免重复计算
            // 扫描
            let scanner = Scanner(string: code!)
            
            var result: UInt32 = 0
            
            // 将结果赋值给result
            scanner.scanHexInt32(&result)
            
            let char = Character(UnicodeScalar(result)!)
            
            // 将code转成emoji表情
            emoji = "\(char)"
        }
    }
    
    open var emoji: String?
    
}

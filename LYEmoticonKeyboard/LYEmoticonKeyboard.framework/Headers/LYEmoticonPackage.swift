//
//  LYEmoticonPackage.swift
//  LYEmoticonKeyboard
//
//  Created by tony on 16/2/24.
//  Copyright © 2016年 tony. All rights reserved.
//

import UIKit

/// 表情包
open class LYEmoticonPackage: NSObject {
    
    let infoName = "emoji.plist"
    /// 表情包标识---对应文件夹
    open var id: String
    
    /// 表情路径类型 -2:表示键盘表情 -1:动态复合路径（内置和沙盒共存，保存最近记录的数据） 0:内置, 1:沙盒路径 2:  default = 0
    open var locationType: Int = 0
    
    /// 表情包名称 --- 用于显示
    open var name: String?
    
    /// 表情封面图片名
    open var posterName: String?
    
    /// 表情所在包名 type = 0时才有用
    open var bundleName: String?
    
    /// 表情包的父目录(相对doc的路径) type = 1时有用
    open var directory: String?
    
    /// 表情包内的表情列表 --- 初始化时赋值
    open var emoticons: [LYEmoticon]?
    
    /// 表情文件路径
    open var infoPlistPath: String? {
        get {
            var plistPath: String?
            // 加载出表情
            switch locationType {
            case -2: // 不考虑内置表情
                break
            case -1:
                break
            case 0:
                var bundlePath: String? = Bundle.main.bundlePath
                if bundleName != nil {
                    bundlePath = Bundle.main.path(forResource: bundleName, ofType: "bundle")
                }
                if bundlePath == nil {
                    break
                }
                
                plistPath = bundlePath! + "/\(id)/\(infoName)"
                break
            case 1:
                
                guard let directory = directory else {
                    break
                }
                
                var paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true);
                let doc = paths[0] as NSString
                
                plistPath = doc.appendingPathComponent("\(directory)/\(id)/\(infoName)")
                break
            default:
                break
            }
            
            return plistPath
        }
    }
    
    /// 表情封面
    open var posterPath: String? {
        get {
            switch locationType {
            case -2:// 不处理
                break
            case -1:
                guard let name = posterName else {
                    return nil
                }
                
                let bundlePath: String = Bundle.main.bundlePath
                let path = bundlePath + "/\(name)"
                return path
            case 0:/// 获取包路径
                guard let name = posterName else {
                    return nil
                }
                
                var bundlePath: String? = Bundle.main.bundlePath
                if bundleName != nil {
                    bundlePath = Bundle.main.path(forResource: bundleName, ofType: "bundle")
                }
                if bundlePath == nil {
                    return nil
                }
                
                let path = bundlePath! + "/\(id)/\(name)"
                return path
            case 1:/// 获取目录路径
                guard let name = posterName else {
                    return nil
                }
                
                guard let directory = directory else {
                    return nil
                }
                
                var paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true);
                let doc = paths[0] as NSString
                
                let path = doc.appendingPathComponent("\(directory)/\(id)/\(name)")
                
                return path
            default:
                break
            }
            
            return nil
        }
    }
    
    //MARK: 初始化构造器
    init(id: String, directory: String?, bundleName: String?, type: Int) {
        self.id = id
        self.directory = directory
        self.bundleName = bundleName
        self.locationType = type
        super.init()
        
        if self.infoPlistPath == nil {
            return
        }
        guard let infoDict = NSDictionary(contentsOfFile: self.infoPlistPath!) else {
            return
        }
        
        self.name = infoDict["name"] as? String
        self.posterName = infoDict["poster"] as? String
        
        /// 提取表情
        let emoticonArr = infoDict["emoticons"] as! [[String: AnyObject]]
        
        emoticons = [LYEmoticon]()
        for dict in emoticonArr {
            // 加载 TODO chs png需要替换
            let name = dict["name"] as? String
            let png = dict["png"] as! String
            let gif = dict["gif"] as! String
            let type = (dict["type"] as! NSString).integerValue
            
            let emoticon = LYEmoticon(id: id, name: name, png: png, gif: gif, fileDirectory: nil, bundleName: bundleName, locationType: 0, type: type)
            
            emoticons?.append(emoticon)
        }
        
    }
    
    //MARK: 用于加载最近使用的表情
    init(id: String, name: String?, posterName: String?, emoticons: [LYEmoticon]!) {
        self.id = id
        self.name = name
        self.posterName = posterName
        self.locationType = -1
        super.init()
        
        self.emoticons = emoticons
    }
    
    // 表情分组 --- 将一种表情拆分中多个页面的块 --- 这里要用对象引用,数组是结构体会被释放
    open var emoticonGroups = [LYEmoticonGroup]()
    
    /// 根据行,列 将表情拆分成多页
    open func loadEmoticonGroups(_ row: Int, column: Int) {
        emoticonGroups.removeAll()
        
        guard let emoticons = self.emoticons else {
            return
        }
        // 每页的表情数量
        let maxCount: Int = row * column
        
        var emoticonSection: LYEmoticonGroup!
        var index: Int = 0
        for emoticon in emoticons {
            
            if index % maxCount == 0 {
                // 满一页的时候创建数组
                emoticonSection = LYEmoticonGroup(id: self.id)
                emoticonGroups.append(emoticonSection)
            }
            
            emoticonSection.emoticons.append(emoticon)
            
            index += 1
        }
        
    }
    
}

open class LYEmoticonGroup: NSObject {
    
    var id: String
    var emoticons = [LYEmoticon]()
    
    init(id: String) {
        self.id = id
        super.init()
    }
    
}

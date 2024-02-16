//
//  LYVideoFilter.swift
//  LYCompositionKit
//
//  Created by tony on 2019/6/1.
//  Copyright © 2019 chengkai. All rights reserved.
//

import UIKit

/**
 * 视频滤镜
 */
open class LYVideoFilter: NSObject, NSCopying, NSCoding {
    
    /// 转场名 --- 展示给用户
    open var title: String
    /// 效果图路径类型 0: 内置 1: 文件系统
    open var type: Int
    /// 转场效果图---app路径
    open var cover: String
    /// 滤镜区域 x, y 是矩形相对值, width, height是绝对值
    open var region: CGRect = .zero // 代表全部
    /// 滤镜名
    open var filterName: String
    /// 滤镜参数
    open var filterSetting: [String: Any]!
    
    public required override init() {
        self.title = "";
        self.type = 0;
        self.cover = "";
        self.region = .zero
        self.filterName = ""
    }
    
    public init(filterName: String) {
        self.title = "";
        self.type = 0;
        self.cover = "";
        self.region = .zero
        self.filterName = ""
    }
    
    // NSCopying
    open func copy(with zone: NSZone?) -> Any {
        let obj = Swift.type(of: self).init();
        obj.title = self.title;
        obj.type = self.type;
        obj.cover = self.cover;
        obj.region = self.region
        obj.filterName = self.filterName
        return obj
    }
    
    func copyAttrs(_ videoTransition:LYVideoTransition) {
        // 如果子类有属性需要拷贝则实现这个方法
    }
    
    // NSCoding
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(self.title, forKey: "title");
        aCoder.encode(self.type, forKey: "type");
        aCoder.encode(self.cover, forKey: "cover");
        aCoder.encode(self.region, forKey: "region");
        aCoder.encode(self.filterName, forKey: "filterName");
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.title = aDecoder.decodeObject(forKey: "title") as! String
        self.cover = aDecoder.decodeObject(forKey: "cover") as! String
        self.type = aDecoder.decodeInteger(forKey: "type")
        self.region = aDecoder.decodeCGRect(forKey: "region")
        self.filterName = aDecoder.decodeObject(forKey: "filterName") as! String
        if self.type == 1 {
            self.cover = self.cover.relativeDocPath();
        }
    }
    
}

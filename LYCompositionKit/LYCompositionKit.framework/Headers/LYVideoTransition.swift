//
//  LYVideoTransition.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import AVFoundation
import CoreMedia
import OpenGLES

/**
 * 该类应该被扩展
 */
open class LYVideoTransition: NSObject, NSCopying, NSCoding {
    
    /// 转场名 --- 展示给用户
    open var title: String
    /// 效果图路径类型 0: 内置 1: 文件系统
    open var type: Int
    /// 转场效果图---app路径
    open var cover: String
    /// shader中内置的转场类型
    open var transitionType: TransitionType = .none
    
    public required override init() {
        self.title = "";
        self.type = 0;
        self.cover = "";
        self.transitionType = .none
    }
    
    public init(transitionType: Int) {
        self.title = "";
        self.type = 0;
        self.cover = "";
        self.transitionType = TransitionType(rawValue: GLint(transitionType)) ?? .none
    }
    
    public init(title: String, type: Int, cover: String, transitionType: Int) {
        self.title = title
        self.type = type
        self.cover = cover
        self.transitionType = TransitionType(rawValue: GLint(transitionType)) ?? .none
    }
    
    /** 配置层指令 */
    open func configLayerInstruction(_ fromLayerInstruction:AVMutableVideoCompositionLayerInstruction, toLayerInstruction:AVMutableVideoCompositionLayerInstruction, renderSize:CGSize,  timeRange:CMTimeRange) {
        
        // 由子类实现
    }
    
    open func convertToDirection(_ directionInt:Int) ->LYTransitionDirection {
        if directionInt < 0 {
            return LYTransitionDirection(rawValue: -1)!;
        }else{
            return LYTransitionDirection(rawValue: directionInt % 4)!;
        }
    }
    
    // NSCopying
    open func copy(with zone: NSZone?) -> Any {
        let obj = Swift.type(of: self).init();
        obj.title = self.title;
        obj.type = self.type;
        obj.cover = self.cover;
        //obj.direction = self.direction;
        obj.transitionType = self.transitionType
        copyAttrs(obj)
        
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
        //aCoder.encode(self.direction.rawValue, forKey: "direction");
        aCoder.encode(self.transitionType.rawValue, forKey: "transitionType");
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.title = aDecoder.decodeObject(forKey: "title") as! String
        self.cover = aDecoder.decodeObject(forKey: "cover") as! String
        self.type = aDecoder.decodeInteger(forKey: "type")
        self.transitionType = TransitionType(rawValue: GLint(aDecoder.decodeInteger(forKey: "transitionType"))) ?? .none
        //self.direction = LYTransitionDirection(rawValue: aDecoder.decodeInteger(forKey: "direction")) ?? .none
        if self.type == 1 {
            self.cover = self.cover.relativeDocPath();
        }
    }
    
}

//
//  LYCompositionUtil.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit
import CoreMedia

/** 创建转场工具 */
open class LYCompositionUtil: NSObject {
    /**
    /** 生成无转场的序列 */
    open class func buildTransitions(_ videos:[LYVideoItem]) ->[LYVideoTransition] {
        var transitionItems = [LYVideoTransition]();
        
        for i:Int in 0 ..< videos.count - 1 {
            if i < videos.count {
                let transition = LYVideoTransition();
                transitionItems.append(transition);
            }
        }
        
        return transitionItems;
    }
    
    /**
     * 生成指定转场,总是比视频片段少一个或多个
     */
    open class func buildTransitions(_ videos:[LYVideoItem], duration:CMTime, clazz:AnyClass) ->[LYVideoTransition] {
        
        var transitionItems = [LYVideoTransition]();
        for i:Int in 0 ..< videos.count - 1 {
            if i < videos.count {
                var transition:LYVideoTransition? = nil;
                if clazz is NoneVideoTransition.Type {// 创建空转场
                    transition = NoneVideoTransition();
                }else if clazz is DissolveVideoTransition.Type {
                    transition = DissolveVideoTransition();
                }else if clazz is PushVideoTransition.Type {
                    transition = PushVideoTransition(directionInt: i, transitionType: 0)
                }else if clazz is WipeVideoTransition.Type {
                    transition = WipeVideoTransition(directionInt: i, transitionType: 0)
                }
                if transition != nil {
                    transitionItems.append(transition!);
                }
            }
        }
        
        return transitionItems;
    }
    
    /** 根据转场实例创建  */
    open class func buildTransitions(_ videoTransition:LYVideoTransition, count:Int, dynamicDirection:Bool) ->[LYVideoTransition] {
        
        var transitionItems = [LYVideoTransition]();
        
        for i:Int in 0 ..< count {
            // 拷贝对象
            let tmpVideoTransition = videoTransition.copy() as! LYVideoTransition;
            if dynamicDirection {// 是否动态创建方向
                //tmpVideoTransition.direction = tmpVideoTransition.convertToDirection(i);
            }
            
            transitionItems.append(tmpVideoTransition);
        }
        
        return transitionItems;
    }
    */
}

//
//  LYCompositionBuilderFactory.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit

/** 组合工厂 */
open class LYCompositionBuilderFactory: NSObject {
    
    /** 创建生成器 --- 根据不同的情况返回不同的生成器 */
    open func builderForTimeline(_ timeline: LYTimeline) ->LYCompositionBuilder {
        
        switch timeline.operationOption {
        case .speed:
            return LYOperationCompositionBuilder(timeline: timeline)
        case .crop, .compress, .reverse:
            return LYManualTransitionCompositionBuilder(timeline: timeline)
        default:
            break
        }
        //return APLTransitionCompositionBuilder(timeline: timeline)
        return LYManualTransitionCompositionBuilder(timeline: timeline)
    }
    
}

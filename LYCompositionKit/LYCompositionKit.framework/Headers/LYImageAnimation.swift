//
//  LYImageAnimation.swift
//  LYCompositionKit
//
//  Created by tony on 2017/8/26.
//  Copyright © 2017年 chengkai. All rights reserved.
//

import Foundation

struct LYImageState {
    
    let scale: CGFloat
    let position: CGPoint
}

/// 图片动画属性
struct LYImageAnimation {
    
    let startState: LYImageState
    let endState: LYImageState
    
    let duration: Double
}

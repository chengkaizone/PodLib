//
//  Constants.swift
//  LYCompositionKit
//
//  Created by tony on 16/6/20.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import Foundation
import AVFoundation
import OpenGLES

// 设置视频的最大尺寸; 对内存没有多大要求
public let VIDEO_SIZE_HIGH: CGFloat = 1920
// 设置图片允许的最大尺寸, 避免内存不足
public let PHOTO_SIZE_HIGH: CGFloat = 1280
// 控制最小的渲染尺寸
public let MIN_RENDER_SIZE: CGFloat = 30
// 限定每秒30帧
public let TIME_SCALE: Int32 = 30
// 截取第一张图片的时间
let copyFirstTime = CMTimeMake(value: 5, timescale: 30)


// 视频转场效果
public enum TransitionType: GLint {
    case none = 0
    case dissolve = 1
    case pinwheel = 2 // 风轮
    case wind = 3
    case ripple = 4
    case pixelize = 5
    case powDistortion = 6
}

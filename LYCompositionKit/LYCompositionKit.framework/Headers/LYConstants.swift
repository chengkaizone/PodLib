//
//  LYConstants.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit
import CoreMedia

// 时长
let TIMELINE_SECONDS:CGFloat = 15.0;
let TIMELINE_WIDTH:CGFloat = 1014.0;

// 图片动画的最大和最小缩放值
let TRANSFORM_MIN_SCALE: CGFloat = 1.1
let TRANSFORM_MAX_SCALE: CGFloat = 2.0

//// 16:9
//let LY1080VideoSize:CGSize = CGSizeMake(1920, 1080);
//
//let LY1080VideoRect:CGRect = CGRectMake(0, 0, 1920, 1080);

// 使用默认转场时间
let defaultTransitionDuration:CMTime = CMTime(value: 1, timescale: 1, flags: CMTimeFlags(rawValue: 1), epoch: 0);
/** 默认音量渐入渐出 1.5 second */
let defaultFadeInOutTime:CMTime = CMTime(value: 3, timescale: 2, flags: CMTimeFlags(rawValue: UInt32(1)), epoch: 0);
/** 默认音量闪避渐入渐出 0.5 second */
let defaultDuckingFadeInOutTime:CMTime = CMTime(value: 1, timescale: 2, flags: CMTimeFlags(rawValue: UInt32(1)), epoch: 0);


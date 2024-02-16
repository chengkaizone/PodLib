//
//  LYTransitionInstructions.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import AVFoundation

/** 转场层指令 */
class LYTransitionInstructions: NSObject {
    
    /** 可变视频组合架构 */
    var compositionInstruction:AVMutableVideoCompositionInstruction!;
    
    /** 层的起始位置 */
    var fromLayerInstruction:AVMutableVideoCompositionLayerInstruction!;
    
    /** 层的结束位置 */
    var toLayerInstruction:AVMutableVideoCompositionLayerInstruction!;
    
    /** 转场对象 */
    var transition:LYVideoTransition!;
    
}


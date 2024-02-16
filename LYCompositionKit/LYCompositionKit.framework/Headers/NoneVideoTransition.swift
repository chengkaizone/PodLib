//
//  NoneVideoTransition.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import AVFoundation
import CoreMedia

/**
 * 创建空转场, 时长为0, 什么都不做
 *
 */
open class NoneVideoTransition: LYVideoTransition {
    
    override open func configLayerInstruction(_ fromLayerInstruction: AVMutableVideoCompositionLayerInstruction, toLayerInstruction: AVMutableVideoCompositionLayerInstruction, renderSize:CGSize, timeRange: CMTimeRange) {
        
    }
    
}


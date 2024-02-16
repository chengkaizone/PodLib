//
//  DissolveVideoTransition.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import AVFoundation
import CoreMedia

/**
 * 简单溶解 导出正常
 */
open class DissolveVideoTransition: LYVideoTransition {
    
    override open func configLayerInstruction(_ fromLayerInstruction: AVMutableVideoCompositionLayerInstruction, toLayerInstruction: AVMutableVideoCompositionLayerInstruction, renderSize:CGSize, timeRange:CMTimeRange) {
        
        fromLayerInstruction.setOpacityRamp(fromStartOpacity: 1.0, toEndOpacity: 0.0, timeRange: timeRange);
        // 这一步最好写上---有些效果不写上预览正常,导出不正常
        toLayerInstruction.setOpacityRamp(fromStartOpacity: 0.1, toEndOpacity: 1.0, timeRange: timeRange);
    }
    
}

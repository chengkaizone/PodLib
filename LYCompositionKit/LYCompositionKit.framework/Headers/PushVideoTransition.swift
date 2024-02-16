//
//  PushVideoTransition.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import AVFoundation
import CoreMedia

/**
 * 推入转场 --- 这里总是假设转场的尺寸是一样大小
 * 支持4个方向
 */
open class PushVideoTransition: LYVideoTransition {
    /*
    override open func configLayerInstruction(_ fromLayerInstruction: AVMutableVideoCompositionLayerInstruction, toLayerInstruction: AVMutableVideoCompositionLayerInstruction, renderSize:CGSize, timeRange: CMTimeRange) {
        
        let fromIdentityTransform = fromLayerInstruction.calculateTransform(renderSize);
        let toIdentityTransform = toLayerInstruction.calculateTransform(renderSize);
        
        let videoWidth = renderSize.width;
        let videoHeight = renderSize.height;
        
        var fromDestTransform = CGAffineTransform.identity;
        var toStartTransform = CGAffineTransform.identity;
        
        switch self.direction {
        case .leftToRight:
            
            fromDestTransform = fromIdentityTransform.concatenating(CGAffineTransform(translationX: videoWidth, y: 0.0));
            toStartTransform = toIdentityTransform.concatenating(CGAffineTransform(translationX: -videoWidth, y: 0.0));
            break;
        case .bottomToTop:
            
            fromDestTransform = fromIdentityTransform.concatenating(CGAffineTransform(translationX: 0.0, y: -videoHeight));
            toStartTransform = toIdentityTransform.concatenating(CGAffineTransform(translationX: 0.0, y: videoHeight));
            break;
        case .rightToLeft:
            
            fromDestTransform = fromIdentityTransform.concatenating(CGAffineTransform(translationX: -videoWidth, y: 0.0));
            toStartTransform = toIdentityTransform.concatenating(CGAffineTransform(translationX: videoWidth, y: 0.0));
            break;
        case .topToBottom:
            
            fromDestTransform = fromIdentityTransform.concatenating(CGAffineTransform(translationX: 0.0, y: videoHeight));
            toStartTransform = toIdentityTransform.concatenating(CGAffineTransform(translationX: 0.0, y: -videoHeight));
            break;
        case .none:
            break;
        }
        
        fromLayerInstruction.setTransformRamp(fromStart: fromIdentityTransform, toEnd: fromDestTransform, timeRange: timeRange);
        toLayerInstruction.setTransformRamp(fromStart: toStartTransform, toEnd: toIdentityTransform, timeRange: timeRange);
        
    }
    */
}

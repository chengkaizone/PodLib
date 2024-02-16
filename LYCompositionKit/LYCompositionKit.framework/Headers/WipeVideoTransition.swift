//
//  WipeVideoTransition.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import AVFoundation
import CoreMedia

/**
 * 擦除---已经解决(非常复杂)
 * 支持4个方向
 */
open class WipeVideoTransition: LYVideoTransition {
    
    /*
    override open func configLayerInstruction(_ fromLayerInstruction: AVMutableVideoCompositionLayerInstruction, toLayerInstruction: AVMutableVideoCompositionLayerInstruction, renderSize:CGSize, timeRange: CMTimeRange) {
        
        let fromAssetTrack = fromLayerInstruction.assetTrack!;
        let toAssetTrack = toLayerInstruction.assetTrack!;
        
        let fromCropRectangle = self.calculateCropRectangle(fromAssetTrack, renderSize: renderSize);
        let toCropRectangle = self.calculateCropRectangle(toAssetTrack, renderSize: renderSize);
        
        DLog("fromLayer: \(fromCropRectangle.startRect)   \(fromCropRectangle.endRect)");
        // 这里转场总是有问题
        fromLayerInstruction.setCropRectangleRamp(fromStartCropRectangle: fromCropRectangle.startRect, toEndCropRectangle: fromCropRectangle.endRect, timeRange: timeRange);
        
        DLog("toLayer: \(toCropRectangle.startRect)   \(toCropRectangle.endRect)");
        toLayerInstruction.setCropRectangleRamp(fromStartCropRectangle: toCropRectangle.startRect, toEndCropRectangle: toCropRectangle.startRect, timeRange: timeRange);
        
    }
    
    /** 配置结算需要裁减的矩形 */
    func calculateCropRectangle(_ assetTrack:AVAssetTrack, renderSize:CGSize) ->(startRect:CGRect, endRect:CGRect) {
        
        // 计算出缩放比例
        let scaleToRatio = renderSize.width / assetTrack.naturalWidth;
//        if assetTrack.preferredTransform.isVertical() {// 竖向拍摄需要旋转
//            scaleToRatio = renderSize.height / assetTrack.naturalSize.width;
//        }
        
        // 计算出需要缩放的宽高
        var videoWidth = renderSize.width;
        var videoHeight = renderSize.height;
        
        if scaleToRatio < 1 {// 需要计算为原始宽高
            videoWidth = renderSize.width / scaleToRatio;
            videoHeight = renderSize.height / scaleToRatio;
        }
        
        let startRect = CGRect(x: 0.0, y: 0.0, width: videoWidth, height: videoHeight);
        var endRect = CGRect(x: 0.0, y: 0.0, width: videoWidth, height: videoHeight);
        
        switch self.direction {
        case .leftToRight:
            endRect = CGRect(x: videoWidth, y: 0.0, width: 0.0, height: videoHeight);
            switch assetTrack.assetAngle() {
            case 0:// 正常拍摄,不处理
                break;
            case 90:
                endRect = CGRect(x: 0.0, y: -videoHeight, width: videoWidth, height: 0.0);
                break;
            case 180:
                endRect = CGRect(x: -videoWidth, y: 0.0, width: 0.0, height: videoHeight);
                break;
            case -90:
                endRect = CGRect(x: 0.0, y: videoHeight, width: videoWidth, height: 0.0);
                break;
            default:
                break;
            }
            break;
        case .bottomToTop:
            endRect = CGRect(x: 0.0, y: -videoHeight, width: videoWidth, height: 0.0);
            switch assetTrack.assetAngle() {
            case 0:// 正常拍摄,不处理
                break;
            case 90:
                endRect = CGRect(x: -videoWidth, y: 0.0, width: 0.0, height: videoHeight);
                break;
            case 180:
                endRect = CGRect(x: 0.0, y: videoHeight, width: videoWidth, height: 0.0);
                break;
            case -90:
                endRect = CGRect(x: videoWidth, y: 0.0, width: 0.0, height: videoHeight);
                break;
            default:
                break;
            }
            break;
        case .rightToLeft:
            endRect = CGRect(x: -videoWidth, y: 0.0, width: 0.0, height: videoHeight);
            switch assetTrack.assetAngle() {
            case 0:// 正常拍摄,不处理
                break;
            case 90:
                endRect = CGRect(x: 0.0, y: videoHeight, width: videoWidth, height: 0.0);
                break;
            case 180:
                endRect = CGRect(x: videoWidth, y: 0.0, width: 0.0, height: videoHeight);
                break;
            case -90:
                endRect = CGRect(x: 0.0, y: -videoHeight, width: videoWidth, height: 0.0);
                break;
            default:
                break;
            }
            break;
        case .topToBottom:
            endRect = CGRect(x: 0.0, y: videoHeight, width: videoWidth, height: 0.0);
            switch assetTrack.assetAngle() {
            case 0:// 正常拍摄,不处理
                break;
            case 90:
                endRect = CGRect(x: videoWidth, y: 0.0, width: 0.0, height: videoHeight);
                break;
            case 180:
                endRect = CGRect(x: 0.0, y: -videoHeight, width: videoWidth, height: 0.0);
                break;
            case -90:
                endRect = CGRect(x: -videoWidth, y: 0.0, width: 0.0, height: videoHeight);
                break;
            default:
                break;
            }
            break;
        case .none:
            break;
        }
        
        return (startRect, endRect);
    }
    */
}

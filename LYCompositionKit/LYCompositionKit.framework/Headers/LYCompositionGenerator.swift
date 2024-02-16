//
//  LYCompositionGenerator.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit
import AVFoundation

/// 组合媒体拆分器
open class LYCompositionGenerator {
    
    open class func shared() ->LYCompositionGenerator {
        struct Static {
            static let instance = LYCompositionGenerator()
        }
        
        return Static.instance
    }
    
    // 生成缩略图并更新视图并返回到主线程
    open class func generatorThumbnails(_ asset: AVAsset, videoComposition: AVVideoComposition?, imageSize: CGSize, unitDuration: TimeInterval, callback: @escaping (_ images: [UIImage], _ completion: Bool) ->Void) {
        
        var images: [UIImage] = []
        let totalDuration = CMTimeGetSeconds(asset.duration)
        
        let imageGenerator = AVAssetImageGenerator(asset: asset);
        imageGenerator.videoComposition = videoComposition
        imageGenerator.requestedTimeToleranceBefore = CMTimeMake(value: 1, timescale: 600)
        imageGenerator.requestedTimeToleranceAfter = CMTimeMake(value: 1, timescale: 600)
        imageGenerator.appliesPreferredTrackTransform = true
        // 自动配置宽高比
        imageGenerator.maximumSize = CGSize(width: imageSize.height * UIScreen.main.scale, height: 0);
        
        var requestedTimes = [NSValue]();
        
        // 计算出需要提取的帧数
        let frames = Int(ceil(CGFloat(totalDuration / unitDuration)))
        let unitTime = CMTimeMake(value: Int64(unitDuration), timescale: 1);
        
        for i:Int64 in 0..<Int64(frames) {
            
            let tmpTime = CMTimeMake(value: unitTime.value * i, timescale: unitTime.timescale);
            requestedTimes.append(NSValue(time: tmpTime));
        }
        
        DLog("\(frames)  \(totalDuration)  \(unitDuration)  \(requestedTimes.count)")
        
        var timeCount = 0
        
        imageGenerator.generateCGImagesAsynchronously(forTimes: requestedTimes) { (requestedTime: CMTime, cgImageRef: CGImage?, actualTime: CMTime, result: AVAssetImageGenerator.Result, error: Error?) in
            
            timeCount += 1
            if result == AVAssetImageGenerator.Result.succeeded {
                
                if cgImageRef != nil {
                    images.append(UIImage(cgImage: cgImageRef!))
                }
            } else {
                if error != nil {
                    DLog("failed! error: \(error!.localizedDescription)")
                }
            }
            
            if timeCount == requestedTimes.count {
                // load done
                DispatchQueue.main.async(execute: { () -> Void in
                    let flag = images.count == requestedTimes.count
                    callback(images, flag)
                })
                
            }
        }
    }
    
}

//
//  LYAssetImageGenerator.swift
//  LYCompositionKit
//
//  Created by tony on 16/5/28.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit
import AVFoundation

open class LYAssetImageGenerator: NSObject {
    
    /// 递归提取视频帧, 会尽可能提取到图片, 适合提取一次的情况, 多次提取的情况效率不高
    open class func copyCGImageAtTime(_ asset: AVAsset, time: CMTime) ->CGImage! {
        
        return copyCGImageAtTime(asset, time: time, videoComposition: nil, maximumSize: nil, loadMetadata: false)
    }
    
    /// 递归提取视频帧, 会尽可能提取到图片, 适合提取一次的情况, 多次提取的情况效率不高
    open class func copyCGImageAtTime(_ asset: AVAsset, time: CMTime, videoComposition: AVVideoComposition?) ->CGImage! {
        
        return copyCGImageAtTime(asset, time: time, videoComposition: videoComposition, maximumSize: nil, loadMetadata: false)
    }
    
    /// 递归提取视频帧, 会尽可能提取到图片, 适合提取一次的情况, 多次提取的情况效率不高
    open class func copyCGImageAtTime(_ asset: AVAsset, time: CMTime, videoComposition: AVVideoComposition?, maximumSize: CGSize?) ->CGImage! {
        
        return copyCGImageAtTime(asset, time: time, videoComposition: videoComposition, maximumSize: maximumSize, loadMetadata: false)
    }
    
    /// 递归提取视频帧, 会尽可能提取到图片, 适合提取一次的情况, 多次提取的情况效率不高
    open class func copyCGImageAtTime(_ asset: AVAsset, time: CMTime, videoComposition: AVVideoComposition?, maximumSize: CGSize?, loadMetadata: Bool) ->CGImage! {
        
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.videoComposition = videoComposition
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceBefore = CMTimeMake(value: 1, timescale: 600)
        imageGenerator.requestedTimeToleranceAfter = CMTimeMake(value: 1, timescale: 600)
        
        if maximumSize != nil {
            imageGenerator.maximumSize = maximumSize!
        }
        
        if loadMetadata == false {// 如果没有加载媒体信息, 手动加载
            let _ = asset.prepare()
        }
        do {
            var actualTime = CMTime.zero
            
            var copyTime = time
            if copyTime == CMTime.zero {
                copyTime = copyFirstTime
            }
            let cgImage = try imageGenerator.copyCGImage(at: copyTime, actualTime: &actualTime)
            return cgImage
        } catch let error as NSError {
            DLog("prepareData generator error: \(error.description)")
        }
        
        let duration = CMTimeGetSeconds(asset.duration)
        // 每次进位1%提取
        let stepTime = CMTimeMakeWithSeconds(duration * 0.01, preferredTimescale: time.timescale)
        let nextTime = CMTimeAdd(time, stepTime)
        
        if CMTimeCompare(nextTime, asset.duration) == 1 {
            return nil
        }
        
        return copyCGImageAtTime(asset, time: nextTime, videoComposition: videoComposition, maximumSize: maximumSize, loadMetadata: loadMetadata)
    }
    
}

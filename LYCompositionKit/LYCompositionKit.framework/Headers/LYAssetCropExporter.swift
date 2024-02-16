//
//  LYAssetCropExporter.swift
//  LYCompositionKit
//
//  Created by tony on 16/4/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit
import AVFoundation

/** 资源裁剪导出 */
open class LYAssetCropExporter: NSObject {
    
    /**
     * 将原始视频处理成方块显示区域
     * 最佳的方块参数
     */
    open class func squareRegion(_ videoUrl: URL!) ->CGRect {
        if videoUrl == nil {
            return CGRect.zero
        }
        
        let asset = AVAsset(url: videoUrl)
        let _ = asset.prepare()
        
        var clipVideoTracks = asset.tracks(withMediaType: AVMediaType.video)
        
        if clipVideoTracks.count == 0 {
            return CGRect.zero
        }
        
        let track = clipVideoTracks[0]
        
        var resultRegion = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        let offset = (track.naturalSize.width - track.naturalSize.height) / 2
        
        let ratioOffset = offset / track.naturalSize.width
        
        //let ratioSize = track.naturalSize.height / track.naturalSize.width
        
        // 竖屏拍摄的情况
        if track.preferredTransform.isVertical() {
            resultRegion = CGRect(x: ratioOffset, y: 0, width: track.naturalSize.height, height: track.naturalSize.height)
        }else{// 横屏拍摄的情况
            
            resultRegion = CGRect(x: 0, y: ratioOffset, width: track.naturalSize.width, height: track.naturalSize.width)
        }
        
        return resultRegion
    }
    
    /**
     * 将视频处理成方块视频 -- 居中裁剪
     * 使用最佳质量的方块尺寸
     */
    open class func squareCrop(_ videoUrl: URL!, saveVideDir: String) ->URL? {
        
        if videoUrl == nil {
            return nil
        }
        
        let asset = AVAsset(url: videoUrl)
        let _ = asset.prepare()
        
        var clipVideoTracks = asset.tracks(withMediaType: AVMediaType.video)
        
        if clipVideoTracks.count == 0 {
            return nil
        }
        
        let track = clipVideoTracks[0]
        
        var offset = (track.naturalSize.height - track.naturalSize.width) / 2
        var tmpSize = track.naturalSize.width
        if track.naturalSize.width > track.naturalSize.height {
            tmpSize = track.naturalSize.height
            offset = (track.naturalSize.width - track.naturalSize.height) / 2
        }
        // 获取最佳的方块尺寸
        let renderSize = CGSize(width: tmpSize, height: tmpSize)
        let instruction = AVMutableVideoCompositionInstruction();

        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: asset.duration)
        
        // 配置通过层的视频指令
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        layerInstruction.assetTrack = track
        
        let txf = track.preferredTransform
        var transform = CGAffineTransform.identity
        
        // 判断矩阵的旋转角度        
        switch txf.angle() {
        case 90:// 竖着拍 --- 目前只会存在竖着的情况
            transform = txf.concatenating(CGAffineTransform(translationX: 0, y: -offset))
            break
        case -90:// 倒竖着拍
            transform = txf.concatenating(CGAffineTransform(translationX: 0, y: -offset))
            break
        case 0:// 顶部向左横拍
            transform = txf.concatenating(CGAffineTransform(translationX: -offset, y: 0))
            break
        case 180:// 顶部向右横拍
            transform = txf.concatenating(CGAffineTransform(translationX: -offset, y: 0))
            break
        default:
            transform = txf.concatenating(CGAffineTransform(translationX: 0, y: -offset))
            break
        }

        // 这里设置计算的方块矩阵区域
        layerInstruction.setTransform(transform, at: CMTime.zero)
        
        instruction.layerInstructions = [layerInstruction];
        
        let videoComposition = AVMutableVideoComposition();
        
        videoComposition.instructions = [instruction]
        videoComposition.renderSize = renderSize
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        videoComposition.renderScale = 1.0
        
        // 这里的预设选择很重要
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else{
            return nil
        }
        
        exportSession.outputURL = uniqueURL(saveVideDir)
        exportSession.outputFileType = AVFileType.mp4
        
        exportSession.videoComposition = videoComposition
        
        var exportFlag = false
        let sema = DispatchSemaphore(value: 0)
        // 这里要处理成同步---
        exportSession.exportAsynchronously(completionHandler: {
            
            switch exportSession.status {
            case .completed:
                exportFlag = true
                break
            case .failed:
                break
            default:
                break
            }
            sema.signal()
        })
        
        let _ = sema.wait(timeout: DispatchTime.distantFuture)
        
        DLog("export result: \(exportFlag)  ->\(String(describing: exportSession.outputURL?.absoluteString))")
        
        if exportFlag {
            return exportSession.outputURL
        }
        
        return nil
    }
    
    /// 返回一个视频保存的唯一地址
    class func uniqueURL(_ videoDir: String) ->URL! {
        let fileManager = FileManager.default;
        if !fileManager.fileExists(atPath: videoDir as String) {
            do {
                try fileManager.createDirectory(atPath: videoDir as String, withIntermediateDirectories: true, attributes: nil);
                
                DLog("create \(videoDir) success!");
            }catch let error as NSError {
                DLog("create dir failed \(error.description)");
                return nil
            }
            
        }
        
        let videoName = "Ying_\(Int64(Date().timeIntervalSince1970)).mov";
        let videoPath = (videoDir as NSString).appendingPathComponent(videoName);
        
        return URL(fileURLWithPath: videoPath)
    }
    
}

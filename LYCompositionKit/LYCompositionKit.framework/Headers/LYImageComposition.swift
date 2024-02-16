//
//  LYImageComposition.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import AssetsLibrary
import AVFoundation

/// 图片合成工具 --- 将图片转换成视频
open class LYImageComposition: NSObject {
    
    /**
     *  将图片转换成视频文件
     *  second: 指定秒数
     *  size: 指定尺寸
     */
    open class func convertToVideo(_ asset:ALAsset, second:Int64, size:CGSize) ->URL? {
        let composition = AVMutableComposition();
        let trackID = kCMPersistentTrackID_Invalid;
        let compositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: trackID);
        // 插入一个空片段
        compositionTrack?.insertEmptyTimeRange(CMTimeRange(start: CMTime.zero, duration: CMTimeMake(value: second, timescale: 1)));
        
        let bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height);
        
        let animationLayer = CALayer();
        animationLayer.frame = bounds;
        
        let videoLayer = CALayer();
        videoLayer.frame = bounds;
        
        animationLayer.addSublayer(videoLayer);
        
        // 创建覆盖物layer
        let imageLayer = makeImageLayer(asset, size: size);
        animationLayer.addSublayer(imageLayer);
        
        animationLayer.isGeometryFlipped = true;
        
        let animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: animationLayer);
        
        let videoComposition = AVMutableVideoComposition(propertiesOf: composition);
        videoComposition.renderSize = size;
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30);
        videoComposition.renderScale = 1.0;
        
        videoComposition.animationTool = animationTool;
        
        let exportPath = createPath();
        // 创建导出会话
        let session = AVAssetExportSession(asset: composition.copy() as! AVAsset, presetName: AVAssetExportPresetHighestQuality)!;
        session.videoComposition = videoComposition;
        session.outputFileType = AVFileType.mp4;
        session.outputURL = URL(fileURLWithPath: exportPath);
        
        /// 这里用信号量转化为同步线程
        let sema = DispatchSemaphore(value: 0);
        
        var flag = false;
        session.exportAsynchronously { () -> Void in
            if(session.status == AVAssetExportSession.Status.completed){
                sema.signal();
                flag = true;
            }else{
                sema.signal();
                flag = false;
                
                DLog("error:\(String(describing: session.error))");
            }
        }
        
        let _ = sema.wait(timeout: DispatchTime.distantFuture);
        
        if flag == true {
            return URL(fileURLWithPath: exportPath);
        }
        
        return nil;
    }
    
    /**
     * 使用指定的尺寸创建layer
     */
    open class func makeImageLayer(_ asset:ALAsset, size:CGSize) ->CALayer {
        let imageRef = asset.defaultRepresentation().fullResolutionImage().takeUnretainedValue();
        
        let imageLayer = CALayer();
        imageLayer.allowsEdgeAntialiasing = true;// 设置边缘抗锯齿
        
        imageLayer.contents = imageRef;
        // 预览,frame和bounds值效果有一定的区别
        imageLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height);
        
        return imageLayer;
    }
    
    /// 创建输出路径
    open class func createPath() ->String {
        var filePath = NSTemporaryDirectory();
        repeat {
            filePath = NSTemporaryDirectory() + String(format: "video-%d.mp4",Int32(Date().timeIntervalSince1970));
            
        } while(FileManager.default.fileExists(atPath: filePath))
        
        return filePath;
    }
    
    /**
     * 使用图片路径创建一个视频路径
     * 使用导出的方式
     */
    open class func buildPhotoVideo(_ photoLayer: CALayer, renderSize: CGSize, placeholderVideo: URL, duration: CMTime) ->URL {
        
        DLog("build start*****")
        let asset = AVAsset(url: placeholderVideo)
        let _ = asset.prepare()
        let composition = AVMutableComposition()
        let trackID:CMPersistentTrackID = kCMPersistentTrackID_Invalid;
        let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: trackID)
        let timeRange = CMTimeRangeMake(start: CMTime.zero, duration: duration)
        
        let videoTracks = asset.tracks(withMediaType: AVMediaType.video)
        let currentTrack = videoTracks[0]
        do {
            
            try compositionVideoTrack?.insertTimeRange(timeRange, of: currentTrack, at: CMTime.zero)
        } catch let error as NSError {
            DLog("image to video error: \(error.description)")
        }
        
        let instruction = AVMutableVideoCompositionInstruction();
        instruction.timeRange = timeRange
        
        let videoComposition = AVMutableVideoComposition();
        
        videoComposition.instructions = [instruction]
        videoComposition.renderSize = renderSize;
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30);
        videoComposition.renderScale = 1.0;
        
        let bound = CGRect(x: 0, y: 0, width: renderSize.width, height: renderSize.height);
        // 被渲染并生成到处使用的最终视频帧
        let animationLayer = CALayer()
        animationLayer.frame = bound
        
        // 组合的视频帧 -- 视频的最终大小
        let videoLayer = CALayer();
        videoLayer.frame = bound;
        
        animationLayer.addSublayer(videoLayer)
        
        animationLayer.addSublayer(photoLayer)
        
        // 设置此项用于保证被正确渲染---不设置将导致图片和文本的位置上下颠倒
        animationLayer.isGeometryFlipped = true;
        
        // 将CoreAnimation图层整合到视频组合中---在视频组合的后期阶段将视频帧和CoreAnimation图层合到一起
        let animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: animationLayer);
        // 添加视频组合属性
        videoComposition.animationTool = animationTool;
        
        let exportSession = AVAssetExportSession(asset: composition.copy() as! AVAsset, presetName: AVAssetExportPresetHighestQuality)!;
        exportSession.videoComposition = videoComposition;
        
        let outputURL = URL(fileURLWithPath: createPath())
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4;
        
        let semaphore = DispatchSemaphore(value: 0)
        exportSession.exportAsynchronously(completionHandler: { () -> Void in
            
            var exportFlag: Bool = false
            switch exportSession.status {
            case .completed:
                exportFlag = true
                break
            case .failed:
                let error = exportSession.error
                if error != nil {
                    DLog("image convert export error: \(error!.localizedDescription)")
                }
                break
            default:
                break
            }
            
            DLog("exportFlag: \(exportFlag)")
            semaphore.signal()
        })
        
        let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        DLog("build end***** \(outputURL.absoluteString)")
        
        return outputURL
    }
    
}


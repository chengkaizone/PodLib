//
//  LYOperationCompositionBuilder.swift
//  LYCompositionKit
//
//  Created by tony on 2017/8/9.
//  Copyright © 2017年 chengkai. All rights reserved.
//

import AVFoundation

/**
 * 资源生成器---只有视频轨道,不含音频
 * 基本资源
 */
class LYOperationCompositionBuilder: NSObject, LYCompositionBuilder {
    
    var timeline:LYTimeline!;
    // 唯一的一个操作实体
    var videoItem: LYVideoItem!
    var composition:AVMutableComposition!;
    
    init(timeline:LYTimeline) {
        self.timeline = timeline;
        self.videoItem = timeline.videos.first!
    }
    
    /** 创建composition */
    func buildComposition() ->LYComposition {
        
        return buildComposition(true, isExport: true)
    }
    
    /**
     * 创建预览
     */
    func buildCompositionPlayback() ->LYComposition {
        return buildComposition(true, isExport: false)
    }
    
    /**
     * 创建导出
     */
    func buildCompositionExport() ->LYComposition {
        return buildComposition(false, isExport: true)
    }
    
    func buildComposition(_ isPlayback: Bool, isExport: Bool) ->LYComposition {
        
        self.composition = AVMutableComposition();
        
        self.addCompositionTracks(mediaItem: videoItem)
        
        // 创建一个默认的导出尺寸
        var renderSize = CGSize(width: 1280, height: 720);// 16:9
        if self.timeline.renderSize != CGSize.zero {
            renderSize = self.timeline.renderSize
        }
        
        let videoComposition = AVMutableVideoComposition(propertiesOf: composition)
        let instruction = videoComposition.instructions.first as! AVMutableVideoCompositionInstruction
        
        let layerInstruction = instruction.layerInstructions.first as! AVMutableVideoCompositionLayerInstruction
        
        layerInstruction.assetTrack = videoItem.asset.tracks(withMediaType: AVMediaType.video).first
        layerInstruction.region = videoItem.region
        layerInstruction.configTransform(renderSize, timeline.operationOption)
        
        videoComposition.renderSize = renderSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        videoComposition.renderScale = 1.0
        
        // 这里保证了videoComposition不为空,所以能获取到renderSize
        //let videoComposition = self.buildVideoCompositionAndInstructions(renderSize);

        return LYOperationComposition(composition: self.composition, videoComposition: videoComposition)
    }
    
    func addCompositionTracks(mediaItem:LYVideoItem) {
        
        let trackID:CMPersistentTrackID = kCMPersistentTrackID_Invalid;
        let compositionVideoTrack = self.composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: trackID);
        let compositionAudioTrack = self.composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: trackID)
        
        // 如果为false 将移除因视频创建的两条空音轨, 才能使导出正常
        var hasAudioTrackData: Bool = false
        
        let cursorTime:CMTime = CMTime.zero;
        
        if mediaItem.asset == nil{
            return
        }
        
        let tracks = mediaItem.asset.tracks(withMediaType: AVMediaType.video)
        if tracks.count == 0 {
            return
        }
        
        mediaItem.startTimeInTimeline = cursorTime
        
        let assetTrack = tracks[0]
        
        // 组合视频通道
        do {
            try compositionVideoTrack?.insertTimeRange(mediaItem.timeRange, of: assetTrack, at: cursorTime);
            DLog("cursorTime: \(CMTimeGetSeconds(cursorTime)) start \(CMTimeGetSeconds(mediaItem.timeRange.start))   duration \(CMTimeGetSeconds(mediaItem.timeRange.duration))")
        } catch let error as NSError {
            DLog("error \(error.description)");
        }
        
        // 是否启用静音
        if timeline.muteEnabled == false {
            let audioTracks = mediaItem.asset.tracks(withMediaType: AVMediaType.audio)
            
            if audioTracks.count > 0 {
                let assetAudioTrack = audioTracks[0]
                
                do {
                    try compositionAudioTrack?.insertTimeRange(mediaItem.timeRange, of: assetAudioTrack, at: cursorTime)
                    
                    hasAudioTrackData = true
                } catch let error as NSError {
                    DLog("error \(error.description)");
                }
            }
        }
        
        switch timeline.operationOption {
            case .speed:
                
                if mediaItem.timeScale != 1.0 {
                    let timeValue = Int64(Double(mediaItem.timeRange.duration.value) * mediaItem.timeScale)
                    let duration = CMTime(value: timeValue, timescale: mediaItem.timeRange.duration.timescale)
                    compositionVideoTrack?.scaleTimeRange(mediaItem.timeRange, toDuration: duration)
                    // 缩放音轨
                    compositionAudioTrack?.scaleTimeRange(mediaItem.timeRange, toDuration: duration)
                }
                
                break
            default:
                break
        }
        
        // 计算下一个时间点
        //cursorTime = CMTimeAdd(cursorTime, mediaItem.timeRange.duration);
        //DLog("addCompositionTrackOfType = \(CMTimeGetSeconds(cursorTime))");
        if hasAudioTrackData == false {
            self.composition.removeTrack(compositionAudioTrack!)
        }
        
    }
    
    /**
     * 创建过渡层指令,手动计算创建可以保证pass比转场至少多一个, 这里操作可能没有自动处理精确
     * 同时要配置track方向, 以及显示区域
     */
    func buildVideoCompositionAndInstructions(_ renderSize:CGSize) ->AVMutableVideoComposition {
        var compositionInstructions = [AVMutableVideoCompositionInstruction]();
        
        let videoTracks = videoItem.asset.tracks(withMediaType: AVMediaType.video)
        let currentTrack = videoTracks.first!
        let option = timeline.operationOption
        
        let instruction = AVMutableVideoCompositionInstruction();
        instruction.timeRange = CMTimeRange(start: CMTime.zero, duration: videoItem.timeRange.duration)
        // 配置通过层的视频指令
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: composition.tracks(withMediaType: AVMediaType.video).first!);
        layerInstruction.assetTrack = currentTrack;
        layerInstruction.region = videoItem.region
        layerInstruction.configTransform(renderSize, option)
        
        instruction.layerInstructions = [layerInstruction];
        compositionInstructions.append(instruction)
        
        let videoComposition = AVMutableVideoComposition();

        // 自定义转场处理类
        // videoComposition.customVideoCompositorClass = nil
        videoComposition.instructions = compositionInstructions;
        videoComposition.renderSize = renderSize;
        videoComposition.frameDuration = CMTime(value: 1, timescale: TIME_SCALE)
        videoComposition.renderScale = 1.0;
        
        //NSLog("instruction: \(instruction.enablePostProcessing)")
        
        return videoComposition;
    }
    
}

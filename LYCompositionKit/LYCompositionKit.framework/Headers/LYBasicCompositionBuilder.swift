//
//  LYBasicCompositionBuilder.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import AVFoundation

/** 
 * 资源生成器---只有视频轨道,不含音频
 * 基本资源
 */
class LYBasicCompositionBuilder: NSObject, LYCompositionBuilder {
    
    var timeline:LYTimeline!;
    var composition:AVMutableComposition!;
    
    init(timeline:LYTimeline) {
        self.timeline = timeline;
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
        
        self.addCompositionTrackOfType(AVMediaType.video, mediaItems: self.timeline.videos);
        
        return LYBasicComposition(composition: self.composition);
    }
    
    func addCompositionTrackOfType(_ mediaType: AVMediaType, mediaItems:[LYMediaItem]?) {
        
        if(mediaItems == nil){
            return;
        }
        
        let trackID:CMPersistentTrackID = kCMPersistentTrackID_Invalid;
        let compositionTrack = self.composition.addMutableTrack(withMediaType: mediaType, preferredTrackID: trackID);
        
        var cursorTime:CMTime = CMTime.zero;
        
        for item:LYMediaItem in mediaItems! {
            
            if item.asset == nil{
                continue
            }
            let tracks = item.asset.tracks(withMediaType: mediaType)
            if tracks.count == 0 {
                continue
            }
            
            item.startTimeInTimeline = cursorTime
            
            let assetTrack = tracks[0]
            
            do {
                try compositionTrack?.insertTimeRange(item.timeRange, of: assetTrack, at: cursorTime);
                DLog("cursorTime: \(CMTimeGetSeconds(cursorTime)) start \(CMTimeGetSeconds(item.timeRange.start))   duration \(CMTimeGetSeconds(item.timeRange.duration))")
            } catch let error as NSError {
                DLog("error \(error.description)");
            }
            
            // 计算下一个时间点
            cursorTime = CMTimeAdd(cursorTime, item.timeRange.duration);
            DLog("addCompositionTrackOfType = \(CMTimeGetSeconds(cursorTime))");
        }
        
    }
    
}

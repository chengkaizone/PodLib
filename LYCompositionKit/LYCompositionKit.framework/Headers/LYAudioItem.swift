//
//  LYAudioItem.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

/** 音乐和录音结构 */
open class LYAudioItem: LYMediaItem {
    
    /// 控制声音的播放时长音量控制
    var volumeAutomation:[LYVolumeAutomation]?;
    
    override public init(localIdentifier: String!) {
        super.init(localIdentifier: localIdentifier)
        
        self.mediaType = .audio
    }
    
    override public init(url: URL!) {
        super.init(url: url);
        
        self.mediaType = .audio
        
        // 需要外部调用 self.prepareAsset()
    }
    
    /** 创建渐入渐出音量 */
    open func buildMusicFades() {
        
        let fadeTime:CMTime = defaultFadeInOutTime;
        var automation = [LYVolumeAutomation]();
        let startRange = CMTimeRangeMake(start: CMTime.zero, duration: fadeTime);
        
        let startVolumeAutomation = LYVolumeAutomation(timeRange: startRange, startVolume: 0.0, endVolume: 1.0);
        automation.append(startVolumeAutomation);
        
        let endRangeStartTime = CMTimeSubtract(self.timeRange.duration, fadeTime);
        let endRange = CMTimeRangeMake(start: endRangeStartTime, duration: fadeTime);
        
        let endVolumeAutomation = LYVolumeAutomation(timeRange: endRange, startVolume: 1.0, endVolume: 0.0);
        
        automation.append(endVolumeAutomation);
        
        self.volumeAutomation = automation;
    }
    
    required public init?(coder aDecoder: NSCoder) {
        
        self.volumeAutomation = aDecoder.decodeObject(forKey: "volumeAutomation") as? [LYVolumeAutomation];
        
        super.init(coder: aDecoder);
    }
    
    // NSCoding 协议
    override open func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.volumeAutomation, forKey: "volumeAutomation");
        
        super.encode(with: aCoder);
    }
    
    override func copyAttrs(_ timelineItem: LYTimelineItem) {
        super.copyAttrs(timelineItem)
        
        let audioItem = timelineItem as! LYAudioItem;
        
        audioItem.volumeAutomation = self.volumeAutomation;
        
        if self.volumeAutomation != nil {
            audioItem.volumeAutomation = [LYVolumeAutomation]();
            
            for item:LYVolumeAutomation in self.volumeAutomation! {
                audioItem.volumeAutomation!.append(item.copy() as! LYVolumeAutomation);
            }
        }
        
    }
    
}

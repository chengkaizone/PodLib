//
//  LYVolumeAutomation.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit
import CoreMedia

/** 音量大小播放的自动化控制 */
open class LYVolumeAutomation: NSObject, NSCopying, NSCoding {
    
    /// 音量范围
    var timeRange:CMTimeRange;
    
    /// 起始音量大小
    var startVolume:CGFloat;
    
    /// 结束音量大小
    var endVolume:CGFloat;
    
    required override public init() {
        self.timeRange = CMTimeRange.zero;
        self.startVolume = 0.0;
        self.endVolume = 0.0;
    }
    
    init(timeRange:CMTimeRange, startVolume:CGFloat, endVolume:CGFloat) {
        
        self.timeRange = timeRange;
        self.startVolume = startVolume;
        self.endVolume = endVolume;
    }
    
    // 初始化音量自动化
    open class func volumeAutomation(_ timeRange:CMTimeRange, startVolume:CGFloat, endVolume:CGFloat) ->LYVolumeAutomation {
        
        return LYVolumeAutomation(timeRange: timeRange, startVolume: startVolume, endVolume: endVolume);
    }
    
    required public init?(coder aDecoder: NSCoder) {
        
        self.timeRange = aDecoder.decodeTimeRange(forKey: "timeRange");
        self.startVolume = CGFloat(aDecoder.decodeFloat(forKey: "startVolume"));
        self.endVolume = CGFloat(aDecoder.decodeFloat(forKey: "endVolume"));
        
    }
    
    // NSCoding 协议
    open func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.timeRange, forKey: "timeRange");
        aCoder.encode(Float(self.startVolume), forKey: "startVolume");
        aCoder.encode(Float(self.endVolume), forKey: "endVolume");
        
    }
    
    // NSCopying
    open func copy(with zone: NSZone?) -> Any {
        
        let volumeAutomation = type(of: self).init();
        
        volumeAutomation.timeRange = self.timeRange;
        volumeAutomation.startVolume = self.startVolume;
        volumeAutomation.endVolume = self.endVolume;
        
        copyAttrs(volumeAutomation);
        
        return volumeAutomation;
    }
    
    func copyAttrs(_ volumeAutomation:LYVolumeAutomation) {
        
        // 由子类实现
    }
    
}


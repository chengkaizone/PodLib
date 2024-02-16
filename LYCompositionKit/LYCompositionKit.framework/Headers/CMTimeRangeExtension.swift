//
//  CMTimeRangeExtension.swift
//  LYCompositionKit
//
//  Created by tony on 2016/11/19.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import Foundation
import CoreMedia

public extension CMTimeRange {
    
    /** 将不同帧率的视频标准化 因为高时基折算可能会出现大于原始值的误差, 很小的误差都会引起黑屏 */
    public func standard(_ timeScale: Int32) ->CMTimeRange {
        
        var tmpStart: CMTime = self.start
        if timeScale < self.start.timescale {
            
            tmpStart = self.start.standard(timeScale)
        }
        
        var tmpDuration: CMTime = self.duration
        if timeScale < self.duration.timescale {
            
            tmpDuration = self.duration.standard(timeScale)
        }
        
        return CMTimeRangeMake(start: tmpStart, duration: tmpDuration)
    }
    
    /** 用默认的30/s标准化 */
    public func standard() ->CMTimeRange {
        
        return self.standard(TIME_SCALE)
    }
    
    
}

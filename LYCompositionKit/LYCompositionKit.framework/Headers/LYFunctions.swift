//
//  LYFunctions.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit
import CoreMedia


class LYFunctions: NSObject {
    
    class func isEmpty(_ object:AnyObject) ->Bool {
        
        return true;
    }
    
    /** 为时间范围获取宽 */
    class func getWidthForTimeRange(_ timeRange:CMTimeRange, scaleFactor:CGFloat) ->CGFloat {
        
        return CGFloat(CMTimeGetSeconds(timeRange.duration)) * scaleFactor;
    }
    
    /** 根据时间点获取在时间轴上的点... */
    class func getOriginForTime(_ time:CMTime) ->CGPoint {
        
        let seconds:CGFloat = CGFloat(CMTimeGetSeconds(time));
        return CGPoint(x: seconds * (TIMELINE_WIDTH / TIMELINE_SECONDS), y: 0);
    }
    
    /** 根据宽度获取时间范围 */
    class func getTimeRangeForWidth(_ width:CGFloat, scaleFactor:CGFloat) ->CMTimeRange {
        let duration:Float64 = Float64(width / scaleFactor);
        
        return CMTimeRangeMake(start: CMTime.zero, duration: CMTimeMakeWithSeconds(duration, preferredTimescale: Int32(NSEC_PER_SEC)));
    }
    
    /** 原始位置返回时间点 */
    class func getTimeForOrigin(_ origin:CGFloat, scaleFactor:CGFloat) ->CMTime {
        let seconds:Float64 = Float64(origin / scaleFactor);
        
        return CMTimeMakeWithSeconds(seconds, preferredTimescale: Int32(NSEC_PER_SEC));
    }
    
    /** 角度转为弧度 */
    class func degreesToRadians(_ degrees:CGFloat) ->CGFloat {
        
        return (degrees * CGFloat(Double.pi) / 180.0);
    }
    
}



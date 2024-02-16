//
//  CMTimeExtension.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import CoreMedia

public extension CMTime {
    
    /** 比较两个影片时间时长是否相等 */
    public func isEqual(_ other:CMTime) ->Bool {
        
        return CMTimeGetSeconds(self) == CMTimeGetSeconds(other);
    }
    
    /** 将不同帧率的视频标准化 因为高时基折算可能会出现大于原始值的误差, 很小的误差都会引起黑屏 */
    public func standard(_ timeScale: Int32) ->CMTime {
        
        // 902400, timescale: 90000  0 6020 600 折算出 903000 9000 所以会出现黑屏
        if timeScale < self.timescale {
            
            let rate = Float(self.timescale) / Float(timeScale)
            let tmpValue = Int64(Float(self.value) / rate)
            return CMTimeMake(value: tmpValue, timescale: timeScale)
        }
        
        return self
    }
    
    /** 用默认的30/s标准化 */
    public func standard() ->CMTime {
        
        return self.standard(TIME_SCALE)
    }
    
    public func progress(_ rate:Float, timeScale:Int32) ->CMTime {
        if(rate < 0.0){
            return CMTime.zero;
        }
        if(rate > 1.0){
            return self;
        }
        
        let totalSec:Float64 = CMTimeGetSeconds(self);
        if totalSec.isFinite == false {
            return CMTime.zero
        }
        let resultSec = totalSec * Float64(rate);
        
        return CMTimeMakeWithSeconds(resultSec, preferredTimescale: timeScale);
    }
    
    /** 转化为字符串的时长 */
    public func convertToSec() ->String {
        
        let totalSec:Float64 = CMTimeGetSeconds(self);
        if totalSec.isFinite == false {
            return "--/--"
        }
        
        let hour = Int(totalSec / 3600);
        let minute = Int(totalSec.truncatingRemainder(dividingBy: 3600) / 60);
        let second = Int((totalSec.truncatingRemainder(dividingBy: 3600)).truncatingRemainder(dividingBy: 60));
        
        var resultDuration = "--/--";
        if(hour != 0){
            resultDuration = NSString(format: "%d:%02d:%02d", hour, minute, second) as String;
        }else{
            resultDuration = NSString(format: "%02d:%02d", minute, second) as String;
        }
        
        return resultDuration;
    }
    
    /** 转化为字符串的时长 */
    public func convertToMsec() ->String {
        
        let totalSec:Float64 = CMTimeGetSeconds(self);
        
        if totalSec.isFinite == false {
            return "--/--"
        }
        
        let hour = Int(totalSec / 3600);
        let minute = Int(totalSec.truncatingRemainder(dividingBy: 3600) / 60);
        let second = Int((totalSec.truncatingRemainder(dividingBy: 3600)).truncatingRemainder(dividingBy: 60));
        let msec = Int(totalSec * 1000) - Int(totalSec) * 1000;
        let msec2 = Int(Double(msec) / 1000.0 * 10.0);
        
        var resultDuration = "--/--";
        if(hour != 0){
            resultDuration = NSString(format: "%d:%02d:%02d.%d", hour, minute, second, msec2) as String;
        }else{
            resultDuration = NSString(format: "%02d:%02d.%d", minute, second, msec2) as String;
        }
        
        return resultDuration;
    }
    
    /** 时长转化为毫秒值 */
    public func milliSecond() ->Int {
        
        let totalSec:Float64 = CMTimeGetSeconds(self);
        
        if totalSec.isFinite == false {
            return Int.max
        }
        
        return Int(totalSec * 1000)
    }
    
    /** 转化为秒数 */
    public func second() ->Int {
        
        let totalSec:Float64 = CMTimeGetSeconds(self);
        
        if totalSec.isFinite == false {
            return Int.max
        }
        
        return Int(totalSec)
    }
    
}

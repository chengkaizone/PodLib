//
//  LYTimelineItem.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit
import CoreMedia

/** 时间轴中的内容 */
open class LYTimelineItem: NSObject, NSCopying, NSCoding {
    
    /// 在时间轴中的时间点, 在视频中不适用, 因为含转场的话是不适用的
    open var startTimeInTimeline:CMTime!;
    
    /// 媒体在timeline中的播放时间范围(start值作为保留项,未使用) --- 这必须弄精确点
    open var timeRange:CMTimeRange!;
    
    /// 是否使用这个资源 default = true
    open var enabled: Bool
    /// 用于关联目标对象, 用于查找判断
    open weak var tag: NSObject?
    
    /// 解决归档对象版本不一致的问题 解决数据模型升级的问题
    var version: Int = 1;
    
    public required override init() {
        
        startTimeInTimeline = CMTime.invalid;
        timeRange = CMTimeRange.invalid;// 使用时一定要赋值
        enabled = true
    }
    
    // NSCopying --- 仅仅用于无参构造器
    open func copy(with zone: NSZone?) -> Any {
        
        let timelineItem = type(of: self).init()
        
        timelineItem.startTimeInTimeline = self.startTimeInTimeline
        timelineItem.timeRange = self.timeRange
        timelineItem.enabled = self.enabled
        timelineItem.version = self.version
        
        copyAttrs(timelineItem);
        
        return timelineItem;
    }
    
    // 由子类调用
    func copyAttrs(_ timelineItem:LYTimelineItem) {
        
    }
    
    // NSCoding
    open func encode(with aCoder: NSCoder) {
        
        if let startTimeInTimeline = self.startTimeInTimeline {// swift类型的结构体归档不允许为可选类型
            aCoder.encode(startTimeInTimeline, forKey: "startTimeInTimeline")
        }
        
        if let timeRange = self.timeRange {
            aCoder.encode(timeRange, forKey: "timeRange")
        }
        
        aCoder.encode(self.enabled, forKey: "enabled")
        aCoder.encode(self.version, forKey: "version");
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        self.startTimeInTimeline = aDecoder.decodeTime(forKey: "startTimeInTimeline");
        self.timeRange = aDecoder.decodeTimeRange(forKey: "timeRange");
        self.enabled = aDecoder.decodeBool(forKey: "enabled")
        self.version = aDecoder.decodeInteger(forKey: "version")
    }
    
}

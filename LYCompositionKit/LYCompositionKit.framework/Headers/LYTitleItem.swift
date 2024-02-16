//
//  LYTitleItem.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import AVFoundation
import QuartzCore
import CoreMedia

/** CoreAnimation层 覆盖物,字幕或者表情 */
open class LYTitleItem: LYTimelineItem {
    
    /**
     * origin属性用于表示覆盖物中心点(非起始点)在视图区域的比例, 对字幕和sticker都有效
     * 对于size只是个比例, 仅仅对sticker等覆盖物有效
     * size中 width 是相对比例, height 是相对 width的比例
     */
    open var ratioRect:CGRect;
    
    /** 矩阵变换 */
    open var transform:CGAffineTransform;
    
    /** 淡入淡出时长 --- 默认设置--- 默认无淡入淡出效果  */
    open var fadeTime:CMTime {
        get {
            if animated {
                return CMTimeMake(value: 1, timescale: 1)
            } else {
                return CMTime.zero
            }
        }
    }
    
    /** 覆盖物是否以渐入渐出动画方式进入 */
    open var animated:Bool = true;
    
    public required init() {
        
        self.ratioRect = CGRect(x: 0, y: 0, width: 0.5, height: 0.5);// 默认设置与渲染大小相同
        self.transform = CGAffineTransform.identity;// 默认不旋转
        
        super.init();
    }
    
    /**
     * 创建预览layer层 size 大小
     */
    open func buildLayer(_ size:CGSize) ->CALayer {
        
        // 子类实现
        return CALayer();
    }
    /**
     * 创建预览layer层 size 大小
     * isRender 是否渲染方式创建,对字体有效
     */
    open func buildLayer(_ size:CGSize, isRender:Bool) ->CALayer {
        
        // 子类实现
        return CALayer();
    }
    
    /** 创建淡入淡出动画 */
    open func makeFadeInFadeOutAnimation() ->CAAnimation {
        
        let keyAnimation = CAKeyframeAnimation(keyPath: "opacity");
        keyAnimation.values = [0.0, 1.0, 1.0, 0.0];
        
        let duration = CMTimeGetSeconds(self.timeRange.duration);
        var ratio = CMTimeGetSeconds(self.fadeTime) / duration;
        if ratio > 0.25 {// 最大为0.25百分比,时长太短的情况
            ratio = 0.25;
        }
        
        // 这个渐入渐出动画的比例应该是计算出来的,渐入时长一般是1~2秒
        keyAnimation.keyTimes = [0.0, NSNumber(value: ratio), NSNumber(value: 1.0 - ratio), 1.0];
        
        let beginCMTime = self.startTimeInTimeline == CMTime.invalid ? CMTime.zero : self.startTimeInTimeline;
        let beginTime = CMTimeGetSeconds(beginCMTime!);// 保证不会出现0.0的情况
        keyAnimation.beginTime = beginTime == 0.0 ? AVCoreAnimationBeginTimeAtZero : beginTime;
        keyAnimation.duration = duration;
        
        keyAnimation.isRemovedOnCompletion = false;// 因为考虑到时机,所以一定不能移除
        
        return keyAnimation;
    }
    
    /** 创建3D闪屏动画 */
    open func make3DSpinAnimation() ->CAAnimation {
        
        let animation = CABasicAnimation(keyPath: "transform.rotation.y");
        animation.toValue = (4 * Double.pi) * -1;
        
        let beginCMTime = self.startTimeInTimeline == CMTime.invalid ? CMTime.zero : self.startTimeInTimeline;
        let beginTime = CMTimeGetSeconds(beginCMTime!) + 0.2;
        animation.beginTime = beginTime == 0.0 ? AVCoreAnimationBeginTimeAtZero : beginTime;
        animation.duration = CMTimeGetSeconds(self.timeRange.duration) * 0.4;
        
        animation.isRemovedOnCompletion = false;
        
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut);
        
        return animation;
    }
    
    /** 创建定时心跳动画 */
    open func makePopAnimation(_ timingOffset:TimeInterval) ->CAAnimation {
        let animation = CABasicAnimation(keyPath: "transform.scale");
        animation.toValue = 1.1;
        
        let beginCMTime = self.startTimeInTimeline == CMTime.invalid ? CMTime.zero : self.startTimeInTimeline;
        let beginTime = CMTimeGetSeconds(beginCMTime!) + timingOffset;
        animation.beginTime = beginTime == 0.0 ? AVCoreAnimationBeginTimeAtZero : beginTime;
        animation.duration = 0.35;
        
        animation.autoreverses = true;
        animation.isRemovedOnCompletion = false;
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut);
        
        return animation;
    }
    
    /** 创建透视矩阵 */
    open func makePerspectiveTransform(_ eyePosition:CGFloat) ->CATransform3D {
        
        var transform = CATransform3DIdentity;
        transform.m34 = -1.0 / eyePosition;
        
        return transform;
    }
    
    // NSCoding 协议
    public required init?(coder aDecoder: NSCoder) {
        
        self.ratioRect = aDecoder.decodeCGRect(forKey: "ratioRect");
        self.transform = aDecoder.decodeCGAffineTransform(forKey: "transform");
        self.animated = aDecoder.decodeBool(forKey: "animated");
        
        super.init(coder: aDecoder);
    }
    
    // NSCoding 协议
    open override func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.ratioRect, forKey: "ratioRect");
        aCoder.encode(self.transform, forKey: "transform");
        aCoder.encode(self.animated, forKey: "animated");
        
        super.encode(with: aCoder);
    }
    
    override func copyAttrs(_ timelineItem: LYTimelineItem) {
        super.copyAttrs(timelineItem)
        
        let titleItem = timelineItem as! LYTitleItem;
        
        titleItem.ratioRect = self.ratioRect;
        titleItem.transform = self.transform;
        titleItem.animated = self.animated;
    }
    
}


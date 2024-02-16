//
//  KenBurnsAnimation.swift
//  LYCompositionKit
//
//  Created by tony on 16/6/20.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit
import AVFoundation

/// KenBurns 效果
open class KenBurnsAnimation: NSObject {
    
    let MIN_SCALE: CGFloat = 1.1
    let MAX_SCALE: CGFloat = 2.0
    
    var images: [UIImage]!
    var frameSize: CGSize!
    var duration: TimeInterval!
    
    /// 创建CALayer
    open class func buildKenBurnsLayer(_ images: [UIImage], frameSize: CGSize, duration: TimeInterval) ->CALayer {
        
        let ken = KenBurnsAnimation()
        ken.images = images
        ken.frameSize = frameSize
        ken.duration = duration
        
        return ken.buildKenBurnsLayer()
    }
    
    /// 创建CALayer
    fileprivate func buildKenBurnsLayer() ->CALayer {
        
        let imageLayer = CALayer()
        imageLayer.bounds = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        imageLayer.contentsGravity = CALayerContentsGravity.resizeAspect
        imageLayer.add(self.kenBurnsAnimation(images), forKey: "KenBurns")
        
        return imageLayer
    }
    
    // 创建动画组
    fileprivate func kenBurnsAnimation(_ images: [UIImage]) ->CAAnimationGroup {
        
        let anim = CAKeyframeAnimation(keyPath: "contents")
        anim.values = images
        anim.keyTimes = self.keyTimes()
        
        let moveAnim = CAKeyframeAnimation(keyPath: "position")
        moveAnim.path = self.trackPath().cgPath
        moveAnim.isAdditive = true //Make the values relative to the current value
        moveAnim.isRemovedOnCompletion = false
        
        let scaleAnim = CAKeyframeAnimation(keyPath: "transform")
        scaleAnim.values = self.scaleArray()
        scaleAnim.isAdditive = true
        scaleAnim.isRemovedOnCompletion = false
        
        let animGroup = CAAnimationGroup()
        animGroup.animations = [anim, moveAnim, scaleAnim]
        animGroup.beginTime = AVCoreAnimationBeginTimeAtZero
        animGroup.duration = self.duration
        animGroup.isRemovedOnCompletion = false
        
        return animGroup
    }
    
    /** 创建关键时间分量 */
    fileprivate func keyTimes() ->[NSNumber] {
        
        var keyTimes = [NSNumber]()
        let step: CGFloat = 1.0 / CGFloat(self.images.count)
        
        for i in 0..<self.images.count {
            keyTimes.append(NSNumber(value: Float(step) * Float(i) as Float))
        }
        
        return keyTimes
    }
    
    /** 创建贝塞尔曲线 */
    fileprivate func trackPath() ->UIBezierPath {
        
        let trackPath = UIBezierPath()
        let startPoint = CGPoint(x: self.frameSize.width / 2, y: self.frameSize.height / 2)
        let maxDeviation = min(self.frameSize.width, self.frameSize.height) * (MIN_SCALE - 1)
        trackPath.move(to: startPoint)
        
        // 随机数
        let random = ((CGFloat(arc4random()).truncatingRemainder(dividingBy: 2)) * 2 - 1)
        
        for _ in 0..<self.images.count {
            let dx = (CGFloat(arc4random()).truncatingRemainder(dividingBy: maxDeviation)) * random
            let dy = (CGFloat(arc4random()).truncatingRemainder(dividingBy: maxDeviation)) * random
            trackPath.addLine(to: CGPoint(x: startPoint.x + dx, y: startPoint.y + dy))
        }
        
        return trackPath
    }
    
    fileprivate func scaleArray() ->[NSValue] {
        
        var scaleArray = [NSValue]()
        
        for _ in 0..<self.images.count {
            let ratio = (Double(arc4random()).truncatingRemainder(dividingBy: 10) / 10.0)
            let scale = (CGFloat(ratio) * (MAX_SCALE - MIN_SCALE)) + MIN_SCALE
            let transform3D = CATransform3DMakeScale(scale, scale, 1.0)
            scaleArray.append(NSValue(caTransform3D: transform3D))
        }
        
        return scaleArray
    }

}

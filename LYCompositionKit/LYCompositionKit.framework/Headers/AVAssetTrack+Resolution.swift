//
//  AVAssetTrack+Resolution.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import AVFoundation

/** 扩展track转角 */
public extension AVAssetTrack {
    
    /// 获取显示中播放看到的宽度
    var naturalWidth: CGFloat {
        get {
            
            let angle = self.assetAngle()
            if angle == 0 || angle == 180 || angle == 360 {
                return self.naturalSize.width
            }
            
            return self.naturalSize.height
        }
    }
    
    /// 获取显示中播放看到的高
    var naturalHeight: CGFloat {
        get {
            
            let angle = self.assetAngle()
            if angle == 0 || angle == 180 || angle == 360 {
                return self.naturalSize.height
            }
            
            return self.naturalSize.width
        }
    }
    
    /** 得到资源的旋转角度
     *  0为正常横向拍摄 180为反横向拍摄 90为竖向拍摄 -90为反竖向拍摄
     */
    public func assetAngle() ->Int {
        
        let transform:CGAffineTransform = self.preferredTransform;
//        let radian = Double(asin(transform.b));// 计算出影片拍摄的弧度---判断拍摄方向
//        var angle = radian * 180.0 / Double.pi;// 转化为角度
//        if (angle == 0 && transform.a < 0){
//            angle = 180;
//        }
        
        return transform.angle();
    }
    
    /** 是否横向 */
    public func isHorizontal() ->Bool {
        
        let angle = self.assetAngle();
        
        if angle % 180 == 0 {
            return true;
        }
        
        return false;
    }
    
    
}


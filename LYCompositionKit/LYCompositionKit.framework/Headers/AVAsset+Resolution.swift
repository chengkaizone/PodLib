//
//  AVAsset+Resolution.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import AVFoundation

public extension AVAsset {
    
    /// 获取文件的字节数
    func fileSize() ->Int {
        
        if let urlAsset = self as? AVURLAsset {
            
            do {
                
                let resourceValues = try urlAsset.url.resourceValues(forKeys: [kCFURLFileSizeKey as URLResourceKey]) as URLResourceValues
                
                if let size = resourceValues.fileSize {
                    return size
                }
            } catch let error {
                DLog("error: \(error.localizedDescription)")
            }
        }
        
        return 0
    }
    
    /// 获取显示中播放看到的宽度
    var naturalWidth: CGFloat {
        get {
    
            let tracks = self.tracks(withMediaType: AVMediaType.video)
            if tracks.count == 0 {
                return 0
            }
            
            let track = tracks[0]
            let angle = self.assetAngle()
            if angle == 0 || angle == 180 || angle == 360 {
                return track.naturalSize.width
            }
            
            return track.naturalSize.height
        }
    }
    
    /// 获取显示中播放看到的高
    var naturalHeight: CGFloat {
        get {
            
            let tracks = self.tracks(withMediaType: AVMediaType.video)
            if tracks.count == 0 {
                return 0
            }
            
            let track = tracks[0]
            let angle = self.assetAngle()
            if angle == 0 || angle == 180 || angle == 360 {
                return track.naturalSize.height
            }
            
            return track.naturalSize.width
        }
    }
    
    /** 得到资源的旋转角度
     *  0为正常横向拍摄 180为反横向拍摄 90为竖向拍摄 -90为反竖向拍摄
     */
    public func assetAngle() ->Int {
        
        let tracks = self.tracks(withMediaType: AVMediaType.video)
        if tracks.count == 0 {
            return 0
        }
        
        let transform:CGAffineTransform = tracks[0].preferredTransform;
        return transform.angle()
    }
    
    /**
     * 是否横向, 视频的真实方向
     */
    public func isHorizontal() ->Bool {
        
        let angle = self.assetAngle();
        
        if angle % 180 == 0 {
            return true;
        }
        
        return false;
    }
    
    /**
     * 是否竖向拍摄
     * 竖拍时width, height需要交换
     */
    public func isVertical() ->Bool {
        
        let angle = self.assetAngle();
        
        if angle % 180 == 0 {
            return false;
        }
        
        return true;
    }
    
    /**
     * 90° 竖屏 获取到的 width: 1920 height: 1080
     * 实际值为 width: 1080 height: 1920
     * 是否横向, 仅仅用于计算渲染尺寸, 考虑了宽高因素
     */
    public func isRelativeHorizontal() ->Bool {
        
        let tracks = self.tracks(withMediaType: AVMediaType.video)
        if tracks.count == 0 {
            return false
        }
        
        let angle = self.assetAngle();

        let track = tracks[0]
        
        if angle % 180 == 0 && track.naturalSize.width >= track.naturalSize.height {
            return true;
        }
        
        return false;
    }
    
}

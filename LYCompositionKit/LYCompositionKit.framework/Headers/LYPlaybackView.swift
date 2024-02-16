//
//  LYPlaybackView.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit
import AVFoundation

/** 视频回放组件 */
open class LYPlaybackView: UIView {
    
    open var player:AVPlayer {
        get {
            return (self.layer as! AVPlayerLayer).player!;
        }
        set {
            (self.layer as! AVPlayerLayer).videoGravity = AVLayerVideoGravity.resizeAspect;
            (self.layer as! AVPlayerLayer).player = newValue;
        }
    };
    
    override open class var layerClass :AnyClass {
        
        return AVPlayerLayer.self;
    }
    
    override open func awakeFromNib() {
        self.backgroundColor = UIColor.black;
    }
    
}

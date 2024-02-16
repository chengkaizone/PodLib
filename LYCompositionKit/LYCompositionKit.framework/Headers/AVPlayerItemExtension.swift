//
//  AVPlayerItemExtension.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import Foundation
import AVFoundation
import CoreMedia

//#include <objc/runtime.h>

private var LYSyncLayer:UInt = 0;
public extension AVPlayerItem {
    
    /** 定义一个扩展属性 */
    public var syncLayer:AVSynchronizedLayer? {
        
        get {
            return objc_getAssociatedObject(self, &LYSyncLayer) as? AVSynchronizedLayer;
        }
        
        set(newValue) {
            objc_setAssociatedObject(self, &LYSyncLayer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }
    
    public func hasValidDuration() ->Bool {
        
        return self.status == AVPlayerItem.Status.readyToPlay && !CMTIME_IS_INVALID(self.duration);
    }
    
    /** 是视频原音的音频轨道静音 */
    public func muteAudioTracks(_ value:Bool) {
        
        for track: AVPlayerItemTrack in self.tracks {
            if track.assetTrack?.mediaType == AVMediaType.audio {
                track.isEnabled = !value
            }
        }
    }
    
}

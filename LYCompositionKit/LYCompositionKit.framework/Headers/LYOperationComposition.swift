//
//  LYOperationComposition.swift
//  LYCompositionKit
//
//  Created by tony on 2017/8/9.
//  Copyright © 2017年 chengkai. All rights reserved.
//

import AVFoundation

// 单个独立功能的操作
class LYOperationComposition: NSObject, LYComposition {
    
    fileprivate var composition:AVComposition!
    fileprivate var videoComposition:AVMutableVideoComposition?;
    
    init(composition:AVComposition, videoComposition:AVMutableVideoComposition?) {
        
        self.composition = composition
        self.videoComposition = videoComposition
    }
    
    class func composition(_ composition:AVComposition, videoComposition:AVMutableVideoComposition?) ->LYOperationComposition {
        
        return LYOperationComposition(composition: composition, videoComposition: videoComposition);
    }
    
    /** 创建预览资源 */
    func makePlayable() ->AVPlayerItem {
        
        let playerItem = AVPlayerItem(asset: self.composition.copy() as! AVAsset);
        playerItem.videoComposition = self.videoComposition
        
        return playerItem
    }
    
    /** 创建导出会话 */
    func makeExportable() ->AVAssetExportSession {
        
        return makeExportable(AVAssetExportPresetHighestQuality);
    }
    
    /** 创建导出会话 */
    func makeExportable(_ exportPreset: String) ->AVAssetExportSession {
        
        let session = AVAssetExportSession(asset: (self.composition.copy() as! AVAsset), presetName: exportPreset)!
        
        session.videoComposition = self.videoComposition
        
        return session
    }
    
    func getVideoComposition() -> AVVideoComposition? {
        
        return videoComposition
    }
    
}

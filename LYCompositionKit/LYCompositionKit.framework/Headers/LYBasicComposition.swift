//
//  LYBasicComposition.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import AVFoundation

class LYBasicComposition: NSObject, LYComposition {
    
    fileprivate var composition:AVComposition!;
    
    init(composition:AVComposition) {
        
        self.composition = composition;
    }
    
    class func composition(_ composition:AVComposition) ->LYBasicComposition {
        
        return LYBasicComposition(composition: composition);
    }
    
    /** 创建预览资源 */
    func makePlayable() ->AVPlayerItem {
        
        return AVPlayerItem(asset: self.composition.copy() as! AVAsset);
    }
    
    /** 创建导出会话 */
    func makeExportable() ->AVAssetExportSession {
        
        return makeExportable(AVAssetExportPresetHighestQuality);
    }
    
    /** 创建导出会话 */
    func makeExportable(_ exportPreset: String) ->AVAssetExportSession {
        
        return AVAssetExportSession(asset: (self.composition.copy() as! AVAsset), presetName: exportPreset)!;
    }
    
    func getVideoComposition() -> AVVideoComposition? {
        
        return nil
    }
    
}


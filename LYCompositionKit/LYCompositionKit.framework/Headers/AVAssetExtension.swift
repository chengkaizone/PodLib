//
//  AVAssetExtension.swift
//  LYCompositionKit
//
//  Created by tony on 16/5/28.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import AVFoundation

extension AVAsset {
    
    /**
     * 提取图片元信息
     */
    func prepare() ->Bool {
        let AVAssetTracksKey = "tracks"
        let AVAssetDurationKey = "duration"
        let AVAssetCommonMetadataKey = "commonMetadata"
        
        var prepared = false
        let semaphore = DispatchSemaphore(value: 0);
        self.loadValuesAsynchronously(forKeys: [AVAssetTracksKey, AVAssetDurationKey, AVAssetCommonMetadataKey]) { () -> Void in
            
            let tracksStatus:AVKeyValueStatus = self.statusOfValue(forKey: AVAssetTracksKey, error: nil);
            let durationStatus:AVKeyValueStatus = self.statusOfValue(forKey: AVAssetDurationKey, error: nil);
            
            prepared = (tracksStatus == AVKeyValueStatus.loaded) && (durationStatus == AVKeyValueStatus.loaded)
            
            if(prepared == false){
                semaphore.signal()
            }else{
                semaphore.signal()
            }
        }
        let _ = semaphore.wait(timeout: .now())
        
        return prepared
    }
    
}

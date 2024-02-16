//
//  LYComposition.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import AVFoundation

/** 合成协议 */
public protocol LYComposition: NSObjectProtocol {
    
    /** 创建影片资源 */
    func makePlayable() ->AVPlayerItem;
    
    /** 创建导出会话 --- 导出最高质量 */
    func makeExportable() ->AVAssetExportSession;
    
    /** 创建导出会话 --- 根据给定的预设创建导出会话 */
    func makeExportable(_ exportPreset: String) ->AVAssetExportSession;
    
    /** 获取合成通道 */
    func getVideoComposition() ->AVVideoComposition?
    
}

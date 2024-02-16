//
//  LYManualTransitionComposition.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit
import AVFoundation
import QuartzCore

/**
 * 手动计算转场过渡合成器
 */
class LYManualTransitionComposition: NSObject, LYComposition {
    
    fileprivate var composition:AVComposition!;
    fileprivate var videoComposition:AVMutableVideoComposition?;
    fileprivate var audioMix:AVAudioMix?;
    
    /** 预览layer */
    fileprivate var playbackLayer:CALayer!
    
    /** 导出渲染的layer */
    fileprivate var renderLayer:CALayer!
    
    /** 水印layer */
    fileprivate var watermarkLayer:CALayer!
    
    
    init(composition:AVComposition, videoComposition:AVMutableVideoComposition?, audioMix:AVAudioMix?, playbackLayer:CALayer?, renderLayer:CALayer?, watermarkLayer:CALayer?) {
        
        self.composition = composition;
        self.videoComposition = videoComposition;
        self.audioMix = audioMix;
        self.playbackLayer = playbackLayer;
        self.renderLayer = renderLayer;
        self.watermarkLayer = watermarkLayer;
        
    }
    
    /** 创建播放资源 */
    func makePlayable() ->AVPlayerItem {
        let playerItem = AVPlayerItem(asset: self.composition.copy() as! AVAsset);
        playerItem.videoComposition = self.videoComposition
        playerItem.audioMix = self.audioMix
        // DLog("makePlayable: \(playerItem.duration)")
        if self.playbackLayer != nil {// 与激活的播放资源时间同步
            let syncLayer = AVSynchronizedLayer(playerItem: playerItem);
            syncLayer.addSublayer(self.playbackLayer!);
            // 引用这个存储属性便于在控制器中添加到视图层
            playerItem.syncLayer = syncLayer;
        }
        
        return playerItem;
    }
    
    /** 创建导出会话 */
    func makeExportable() ->AVAssetExportSession {
        
        return makeExportable(AVAssetExportPresetHighestQuality);
    }
    
    /**
     * 创建导出会话
     * 留出预设名可以给外层更多选择
     */
    func makeExportable(_ exportPreset: String) ->AVAssetExportSession {
        
        var size = CGSize(width: 1280, height: 720);// 默认尺寸
        
        if self.videoComposition != nil {// 过渡可能为空
            size = self.videoComposition!.renderSize;
        }
        let bound = CGRect(x: 0, y: 0, width: size.width, height: size.height);
        // 被渲染并生成到处使用的最终视频帧
        let animationLayer = CALayer();
        animationLayer.frame = bound;
        
        // 组合的视频帧 -- 视频的最终大小
        let videoLayer = CALayer();
        videoLayer.frame = bound;
        
        animationLayer.addSublayer(videoLayer);
        if self.renderLayer != nil {
            animationLayer.addSublayer(self.renderLayer!);
        }
        
        if self.watermarkLayer != nil {
            animationLayer.addSublayer(self.watermarkLayer!);
        }
        // 设置此项用于保证被正确渲染---不设置将导致图片和文本的位置上下颠倒
        animationLayer.isGeometryFlipped = true;
        
        // 将CoreAnimation图层整合到视频组合中---在视频组合的后期阶段将视频帧和CoreAnimation图层合到一起
        let animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: animationLayer);
        // 添加视频组合属性
        self.videoComposition?.animationTool = animationTool;
        
        let session = AVAssetExportSession(asset: self.composition.copy() as! AVAsset, presetName: exportPreset)!;
        session.audioMix = self.audioMix;
        session.videoComposition = self.videoComposition;
        
        return session;
    }
    
    func getVideoComposition() -> AVVideoComposition? {
        
        return videoComposition
    }
    
}


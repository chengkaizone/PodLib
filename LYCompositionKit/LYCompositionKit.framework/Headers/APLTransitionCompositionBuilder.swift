//
//  APLCompositionBuilder.swift
//  LYCompositionKit
//
//  Created by tony on 2019/6/1.
//  Copyright © 2019 chengkai. All rights reserved.
//

import AVFoundation
import CoreMedia
import Photos
import OpenGLES

/**
 * 手动计算视频转场过渡生成器
 */
class APLTransitionCompositionBuilder: NSObject, LYCompositionBuilder {
    
    fileprivate var timeline: LYTimeline
    fileprivate var composition: AVMutableComposition!
    fileprivate var videoComposition: AVVideoComposition?
    
    // 视频中的音频混合参数
    fileprivate var videoAudioMixInputParameters: [AVMutableAudioMixInputParameters]!
    
    fileprivate var musicAudioTrack: AVMutableCompositionTrack?
    fileprivate var voiceAudioTrack: AVMutableCompositionTrack?
    
    fileprivate var passThroughTimeRanges: [CMTimeRange]
    fileprivate var transitionTimeRanges: [CMTimeRange]
    
    fileprivate var placeholderAsset: AVAsset!
    fileprivate var placeholderTrack: AVAssetTrack!
    
    fileprivate var eaglContext: EAGLContext! = {
        return EAGLContext(api: EAGLRenderingAPI.openGLES3)
    }()
    fileprivate lazy var ciContext: CIContext = {
        let options = [CIContextOption.workingColorSpace: NSNull()]
        let context = CIContext(eaglContext: eaglContext, options: options)
        return context
    }()
    
    // 片尾的空镜头
    fileprivate var emptyVideoItem: LYVideoItem! {
        
        if self.timeline.watermarkEnabled {
            let item = LYVideoItem.empty(duration: self.timeline.watermarkDuration)
            item.asset = placeholderAsset
            
            return item
        }
        
        return nil
    }
    fileprivate var watermarkStartTimeline: CMTime!
    
    init(timeline:LYTimeline) {
        
        self.timeline = timeline;
        
        self.placeholderAsset = AVAsset(url: timeline.placeholderVideoURL as URL)
        let _ = self.placeholderAsset.prepare()
        self.placeholderTrack = self.placeholderAsset.tracks(withMediaType: AVMediaType.video)[0]
        
        self.videoAudioMixInputParameters = [AVMutableAudioMixInputParameters]()
        
        self.passThroughTimeRanges = [CMTimeRange]();
        self.transitionTimeRanges = [CMTimeRange]();
    }
    
    /** 创建composition */
    func buildComposition() ->LYComposition {
        
        return buildComposition(true, isExport: true)
    }
    
    /**
     * 创建预览
     */
    func buildCompositionPlayback() ->LYComposition {
        return buildComposition(true, isExport: false)
    }
    
    /**
     * 创建导出
     */
    func buildCompositionExport() ->LYComposition {
        return buildComposition(false, isExport: true)
    }
    
    /**
     * 创建composition
     * 选择性创建预览和导出
     */
    func buildComposition(_ isPlayback: Bool, isExport: Bool) ->LYComposition {
        self.composition = AVMutableComposition()
        self.buildCompositionTracks()// 创建track 并计算出通过和过渡时间段
        // 创建一个默认的导出尺寸
        var renderSize = CGSize(width: 1280, height: 720);// 16:9
        if self.timeline.renderSize != CGSize.zero {
            renderSize = self.timeline.renderSize
        }
        // 这里保证了videoComposition不为空,所以能获取到renderSize
        let videoComposition = self.buildVideoCompositionAndInstructions(composition, renderSize)
        
        // 这一步必须最后一步创建才能保证音频有值
        let audioMix = self.buildAudioMix();
        
        let playbackSize = self.timeline.playbackSize;
        
        // 创建覆盖物 --- 含图片, sticker, 字幕通道
        var playbackLayer: CALayer!
        if isPlayback {
            playbackLayer = self.buildLayer(playbackSize, isRender:false)
        }
        
        // 使用最合理的尺寸
        var renderLayer: CALayer!
        if isExport {
            renderLayer = self.buildLayer(renderSize, isRender:true)
        }
        
        //let watermarkLayer: CALayer! = self.buildWatermarkLayer(renderSize)
        
        return LYManualTransitionComposition(composition: composition, videoComposition: videoComposition, audioMix: audioMix, playbackLayer: playbackLayer, renderLayer: renderLayer, watermarkLayer: nil);
    }
    
    /**
     * 创建A-B通道
     * 更复杂的效果,比如模糊背景可能需要用到AA-BB模式
     */
    func buildCompositionTracks() {
        
        let trackID:CMPersistentTrackID = kCMPersistentTrackID_Invalid;
        let compositionVideoTrackA = self.composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: trackID);
        let compositionVideoTrackB = self.composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: trackID);
        
        let videoCompositionTracks = [compositionVideoTrackA, compositionVideoTrackB];
        
        /**
         * 创建音频轨道 --- 也使用过渡效果
         * 如果创建了轨道, 但是没有插入数据的话将导致导出失败(至少要保证一个音轨有数据才能成功导出)
         */
        let compositionAudioTrackA = self.composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: trackID)
        let compositionAudioTrackB = self.composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: trackID)
        let audioCompositionTracks = [compositionAudioTrackA, compositionAudioTrackB]
        // 如果为false 将移除因视频创建的两条空音轨, 才能使导出正常
        var hasAudioTrackData: Bool = false
        var cursorTime = CMTime.zero
        let watermarkEnabled = self.timeline.watermarkEnabled
        var videos = self.timeline.videos;
        if watermarkEnabled { // 片尾镜头
            videos.append(emptyVideoItem)
        }
        let videoCount = videos.count;
        for i:Int in 0 ..< videoCount {
            let trackIndex = i % 2;
            let videoItem = videos[i]
            var videoItemNext: LYVideoItem!
            if i < videoCount - 1 {
                videoItemNext = videos[i + 1]
            }
            
            let currentVideoTrack = videoCompositionTracks[trackIndex]
            let currentAudioTrack = audioCompositionTracks[trackIndex]
            do {
                
                if videoItem.mediaType == .video || videoItem.mediaType == .unknown {
                    let videoTracks = videoItem.asset.tracks(withMediaType: AVMediaType.video)
                    
                    if videoTracks.count > 0 {
                        let assetVideoTrack = videoTracks[0];
                        // 这里记录在时间轴中的起点
                        videoItem.startTimeInTimeline = cursorTime
                        if videoItem.mediaType == .unknown {// 片尾的情况
                            watermarkStartTimeline = cursorTime
                        }
                        try currentVideoTrack?.insertTimeRange(videoItem.timeRange, of: assetVideoTrack, at: cursorTime);
                    }
                    
                    // 是否启用静音
                    if timeline.muteEnabled == false {
                        let audioTracks = videoItem.asset.tracks(withMediaType: AVMediaType.audio)
                        if audioTracks.count > 0 {
                            let assetAudioTrack = audioTracks[0]
                            try currentAudioTrack?.insertTimeRange(videoItem.timeRange, of: assetAudioTrack, at: cursorTime)
                            
                            hasAudioTrackData = true
                        }
                    }
                } else {// 图片或片尾的情况 --- 使用导出的视频, 如果图片定义的时间太长, 此处需要循环插入
                    videoItem.startTimeInTimeline = cursorTime
                    if videoItem.mediaType == .unknown {// 片尾的情况
                        watermarkStartTimeline = cursorTime
                    }
                    // 应该的结束时间
                    let endTimeline = CMTimeAdd(videoItem.startTimeInTimeline, videoItem.timeRange.duration)
                    var tmpCursorTime = cursorTime
                    
                    // 每次递增的时长
                    let stepDuration = self.placeholderAsset.duration
                    
                    // 需要做特殊处理 如果裁剪资源的时长很小,需要重复组合这段资源
                    repeat {
                        // 时长需要再次计算 --- 每次更新cursorTime后 --- 可能需要截断
                        var insertDuration = CMTimeSubtract(endTimeline, tmpCursorTime)
                        if CMTimeCompare(insertDuration, stepDuration) == 1 {
                            insertDuration = stepDuration
                        }
                        // 插入的资源范围
                        try currentVideoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: insertDuration), of: self.placeholderTrack, at: tmpCursorTime);
                        
                        tmpCursorTime = CMTimeAdd(tmpCursorTime, insertDuration)
                    } while(CMTimeCompare(tmpCursorTime, endTimeline) == -1)
                    
                }
            } catch let error as NSError {
                DLog("error:\(error.description)");
            }
            
            // 计算出本次转场时间 --- 并记录前后转场的时间
            let transitionDuration = videoItem.calculateTransitionTime(videoItemNext, maxTransitionTime: defaultTransitionDuration)
            
            // 计算转场/通过的时间范围
            var timeRange = CMTimeRangeMake(start: cursorTime, duration: videoItem.timeRange.duration);
            if i > 0 {// 计算通过时间段---计算前一个转场时间
                var preTransitionDuration = CMTime.zero
                if self.transitionTimeRanges.last != nil {
                    preTransitionDuration = self.transitionTimeRanges.last!.duration
                }
                timeRange.start = CMTimeAdd(timeRange.start, preTransitionDuration);
                timeRange.duration = CMTimeSubtract(timeRange.duration, preTransitionDuration);
            }
            if i < videoCount - 1 {// 计算出通过的时间区域
                let deltaDuration = CMTimeSubtract(timeRange.duration, transitionDuration)
                timeRange.duration = deltaDuration
            }
            self.passThroughTimeRanges.append(timeRange)
            cursorTime = CMTimeAdd(cursorTime, videoItem.timeRange.duration);
            //这里需要正常序列的转场时长,最后一个为任何时长都会被忽略
            cursorTime = CMTimeSubtract(cursorTime, transitionDuration);
            if i < videoCount - 1 {// 计算转场过渡时间段 --- 这里用的正常序列时长
                timeRange = CMTimeRangeMake(start: cursorTime, duration: transitionDuration);
                if watermarkEnabled {// 如果最后一个实际片段
                    if i < videoCount - 2 {
                        self.transitionTimeRanges.append(timeRange);
                    }
                } else {
                    self.transitionTimeRanges.append(timeRange);
                }
            }
        }
        
        if hasAudioTrackData == false {
            for audioTrack in audioCompositionTracks {
                self.composition.removeTrack(audioTrack!)
            }
        }
        DLog("passThroughTimeRanges: \(transitionTimeRanges.count)  \(passThroughTimeRanges.count)   \(self.timeline.videos.count)")
        // 创建画外音轨道
        self.voiceAudioTrack = self.addCompositionTrackOfType(AVMediaType.audio, mediaItems: self.timeline.voices, type: 1);
        // 得到最后合成的音频混合
        self.musicAudioTrack = self.addCompositionTrackOfType(AVMediaType.audio, mediaItems: self.timeline.musics, type: 0);
    }
    
    /**
     * 创建过渡层指令,手动计算创建可以保证pass比转场至少多一个
     * 同时要配置track方向, 以及显示区域
     */
    func buildVideoCompositionAndInstructions(_ asset: AVAsset, _ renderSize:CGSize) ->AVMutableVideoComposition {
        
        //print("是否含有滤镜---> \(timeline.filter)")
        // 支持全局滤镜, 自定义合成器，这里不执行
        let videoComposition = AVMutableVideoComposition(asset: asset) { (request: AVAsynchronousCIImageFilteringRequest) in
            //NSLog("执行滤镜~~~")
            guard let ciFilter = self.timeline.filter else {
                //NSLog("执行滤镜~~~》》《《")
                request.finish(with: request.sourceImage.clampedToExtent(), context: nil)
                return
            }
            //NSLog("执行滤镜>>>")
            let source = request.sourceImage.clampedToExtent()
            ciFilter.setValue(source, forKey: kCIInputImageKey)
            let output = ciFilter.outputImage!.cropped(to: request.sourceImage.extent)
            request.finish(with: output, context: nil)
        }
        videoComposition.customVideoCompositorClass = APLCustomVideoCompositor.self
        var compositionInstructions = [AVVideoCompositionInstructionProtocol]()
        // 获取到视频和音频轨道
        let compositionVideoTracks = self.composition.tracks(withMediaType: AVMediaType.video)
        let compositionAudioTracks = self.composition.tracks(withMediaType: AVMediaType.audio)
        let watermarkEnabled = self.timeline.watermarkEnabled
        var videos = self.timeline.videos;
        if watermarkEnabled { // 片尾镜头
            videos.append(emptyVideoItem)
        }
        
        let videoTrackID0 = compositionVideoTracks[0].trackID
        let videoTrackID1 = compositionVideoTracks[1].trackID
        for i:Int in 0 ..< self.passThroughTimeRanges.count {
            let trackIndex = i % 2;
            let foregroundTrackID = compositionVideoTracks[trackIndex].trackID
            let backgroundTrackID = compositionVideoTracks[1 - trackIndex].trackID
            let videoItem = videos[i]
            
            var nextItem: LYVideoItem? = nil
            if i < self.passThroughTimeRanges.count - 1 {
                nextItem = videos[i + 1];
            }
            // 默认处理为图片的情况
            var assetTrack = self.placeholderTrack
            if videoItem.asset != nil {// 视频的情况
                let tracks = videoItem.asset.tracks(withMediaType: AVMediaType.video)
                assetTrack = tracks.first
            }
            let passTimeRange = self.passThroughTimeRanges[i]
            
            // 处理定制层指令
            if videoComposition.customVideoCompositorClass != nil {
                let instruction = APLCustomVideoCompositionInstruction(passthroughTrackID: foregroundTrackID, forTimeRange: passThroughTimeRanges[i])
                compositionInstructions.append(instruction)
            }
            // 创建转场过渡指令
            if i < self.transitionTimeRanges.count {
                let transitionTimeRange = transitionTimeRanges[i]
                if videoComposition.customVideoCompositorClass != nil {
                    let sourceTrackIDs = [NSNumber(integerLiteral: Int(videoTrackID0)), NSNumber(integerLiteral: Int(videoTrackID1))]
                    var transitionType: TransitionType = TransitionType.none
                    if let videoTransition = videoItem.videoTransition {
                        transitionType = videoTransition.transitionType
                    }
                    let instruction = APLCustomVideoCompositionInstruction(sourceTrackIDs: sourceTrackIDs, forTimeRange: transitionTimeRange, transitionType: transitionType)
                    instruction.foregroundTrackID = foregroundTrackID
                    instruction.backgroundTrackID = backgroundTrackID
                    compositionInstructions.append(instruction);
                }
                
                // 视频原音的音量
                let videoVolume = timeline.videoVolume
                if compositionAudioTracks.count > trackIndex {// 视频中可能不包含音频轨道
                    let parametersA = AVMutableAudioMixInputParameters(track: compositionAudioTracks[trackIndex])
                    if videoItem.muteEnabled == false {
                        parametersA.setVolumeRamp(fromStartVolume: videoVolume, toEndVolume: videoVolume, timeRange: passTimeRange)
                        if timeline.videoAudioMixTransitionEnabled {
                            parametersA.setVolumeRamp(fromStartVolume: videoVolume, toEndVolume: 0.0, timeRange: transitionTimeRange)
                        }
                    } else {
                        parametersA.setVolumeRamp(fromStartVolume: 0.0, toEndVolume: 0.0, timeRange: passTimeRange)
                        parametersA.setVolumeRamp(fromStartVolume: 0.0, toEndVolume: 0.0, timeRange: transitionTimeRange)
                    }
                    self.videoAudioMixInputParameters.append(parametersA)
                }
                if compositionAudioTracks.count > 1 - trackIndex {// 视频中可能不包含音频轨道
                    let parametersB = AVMutableAudioMixInputParameters(track: compositionAudioTracks[1 - trackIndex])
                    if nextItem != nil && nextItem!.muteEnabled == false {
                        parametersB.setVolumeRamp(fromStartVolume: videoVolume, toEndVolume: videoVolume, timeRange: passTimeRange)
                        if timeline.videoAudioMixTransitionEnabled {
                            parametersB.setVolumeRamp(fromStartVolume: 0.0, toEndVolume: videoVolume, timeRange: transitionTimeRange)
                        }
                    } else {
                        parametersB.setVolumeRamp(fromStartVolume: 0.0, toEndVolume: 0.0, timeRange: passTimeRange)
                        parametersB.setVolumeRamp(fromStartVolume: 0.0, toEndVolume: 0.0, timeRange: transitionTimeRange)
                    }
                    self.videoAudioMixInputParameters.append(parametersB)
                }
            } else {
            }
        }
        
        videoComposition.instructions = compositionInstructions;
        videoComposition.renderSize = renderSize;
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: TIME_SCALE);
        videoComposition.renderScale = 1.0;
        return videoComposition;
    }
    
    /** 根据类型创建合成通道 背景音,画外音 没有转场重叠过渡  音轨和视频轨道 type = 0 music, type = 1 voice */
    func addCompositionTrackOfType(_ mediaType: AVMediaType, mediaItems:[LYMediaItem]?, type: Int) ->AVMutableCompositionTrack? {
        
        if mediaItems == nil || mediaItems!.count == 0 {
            return nil;
        }
        
        let compositionTrack = self.composition.addMutableTrack(withMediaType: mediaType, preferredTrackID: kCMPersistentTrackID_Invalid);
        
        // 注意音频必须按时间先后插入轨道,否则会出现一些问题
        let audioItems = timeline.sortAudios(mediaItems as? [LYAudioItem])!
        for item:LYMediaItem in audioItems {
            
            if item.enabled == false {
                continue
            }
            
            if item.asset == nil {
                continue
            }
            
            var startTimeInTimeline = item.startTimeInTimeline!
            if startTimeInTimeline == CMTime.invalid {
                startTimeInTimeline = CMTime.zero
            }
            
            // 可能会修改时长, 不修改起点
            var timeRange = item.timeRange!
            
            let timelineDuration = timeRange.duration
            
            /// timeline中的结束时间 --- 这里要自动修复处理这个时长必须在下一个点之前
            var endTimeline = CMTimeAdd(startTimeInTimeline, timelineDuration)
            
            // 取得组合时长, 音轨的时长不能超出这个时长 --- 音乐的实际时长
            var reachTime = timeline.queryReachTimeWithAudio(item, type: type)
            
            if CMTimeCompare(reachTime, CMTime.zero) == 0 {
                reachTime = self.composition.duration
            }
            
            // 判断是否越界
            let result = CMTimeCompare(endTimeline, reachTime)
            
            switch result {
            case -1, 0: //  小于或等于总时长 不需要修剪范围
                break
            case 1:
                // 时间差  --- 计算出允许的时间范围(避免出界)
                let delta = CMTimeSubtract(endTimeline, reachTime)
                timeRange.duration = CMTimeSubtract(timeRange.duration, delta)
                // 重新指向最后到达的时间点
                endTimeline = reachTime
                break
            default:
                break
            }
            
            let audioTracks = item.asset.tracks(withMediaType: mediaType)
            
            if audioTracks.count == 0 {// 做一次安全检查, UI层没处理好的话不至于crash
                continue
            }
            // 这里有问题? 注意音频的时长不能超过视频的时长否则,视频不可见
            let assetTrack = audioTracks[0]
            
            do {
                var cursorTime = startTimeInTimeline
                
                // 计算出插入时长
                var stepDuration = timeRange.duration
                // 插入音频范围太长的情况处理
                if CMTimeCompare(timeRange.duration, item.assetTimeRange.duration) == 1 {
                    stepDuration = item.assetTimeRange.duration
                }
                
                // 需要做特殊处理 如果裁剪资源的时长很小,需要重复组合这段资源
                repeat {
                    // 时长需要再次计算 --- 每次更新cursorTime后 --- 可能需要截断
                    var insertDuration = CMTimeSubtract(endTimeline, cursorTime)
                    if CMTimeCompare(insertDuration, stepDuration) == 1 {
                        insertDuration = stepDuration
                    }
                    
                    // 插入的资源范围
                    try compositionTrack?.insertTimeRange(CMTimeRangeMake(start: item.assetTimeRange.start, duration: insertDuration), of: assetTrack, at: cursorTime)
                    
                    cursorTime = CMTimeAdd(cursorTime, insertDuration)
                    
                }while(CMTimeCompare(cursorTime, endTimeline) == -1)
                
            }catch let error as NSError {
                DLog("error:\(error.description)");
            }
            
        }
        
        return compositionTrack;
    }
    
    /** 音频混合自动音量设置  */
    func buildAudioMixInputParameter(_ audioTrack: AVMutableCompositionTrack?, audioItems: [LYAudioItem]?) ->AVMutableAudioMixInputParameters? {
        
        if audioTrack == nil {
            return nil
        }
        
        guard let musics = audioItems else {
            return nil
        }
        
        let parameters = AVMutableAudioMixInputParameters(track: audioTrack);
        for item in musics {
            
            if item.volumeAutomation != nil {
                for automation:LYVolumeAutomation in item.volumeAutomation! {
                    if timeline.audioDisabled {
                        parameters.setVolumeRamp(fromStartVolume: 0.0, toEndVolume: 0.0, timeRange: automation.timeRange)
                    }else {
                        parameters.setVolumeRamp(fromStartVolume: Float(automation.startVolume), toEndVolume: Float(automation.endVolume), timeRange: automation.timeRange)
                    }
                }
            } else {
                var audioVolume = 1 - timeline.videoVolume
                if timeline.audioDisabled {
                    audioVolume = 0
                }
                parameters.setVolumeRamp(fromStartVolume: Float(audioVolume), toEndVolume: Float(audioVolume), timeRange: item.timeRange);
            }
            
        }
        
        return parameters
    }
    
    /** 音频混合自动音量设置 背景音乐和话外音 */
    func buildAudioMix() ->AVAudioMix? {
        
        let audioMix = AVMutableAudioMix();
        
        for videoAudioMix in self.videoAudioMixInputParameters {
            audioMix.inputParameters.append(videoAudioMix)
        }
        
        let musicMix = buildAudioMixInputParameter(self.musicAudioTrack, audioItems: self.timeline.musics)
        let voiceMix = buildAudioMixInputParameter(self.voiceAudioTrack, audioItems: self.timeline.voices)
        
        if musicMix != nil {
            audioMix.inputParameters.append(musicMix!)
        }
        
        if voiceMix != nil {
            audioMix.inputParameters.append(voiceMix!)
        }
        
        return audioMix;
    }
    
    /**
     * 创建覆盖物图层
     * size目前只用到预览和导出两种size
     * isExport 是否是导出渲染
     */
    func buildLayer(_ size:CGSize, isRender:Bool) ->CALayer? {
        
        let photoLayer = self.buildPhotoLayer(size, isRender: isRender)
        let stickerLayer = self.buildStickerLayer(size);
        let subtitleLayer = self.buildSubtitleLayer(size, isRender: isRender);
        
        let parentLayer = CALayer();
        parentLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height);
        parentLayer.anchorPoint = CGPoint.zero;
        
        if photoLayer != nil {
            parentLayer.addSublayer(photoLayer!)
        }
        
        if stickerLayer != nil {
            parentLayer.addSublayer(stickerLayer!);
        }
        
        // 字幕图层需要在贴图的上方
        if subtitleLayer != nil {
            parentLayer.addSublayer(subtitleLayer!);
        }
        
        if self.timeline.watermarkEnabled {
            let watermarkLayer = self.buildWatermarkLayer(size, isRender: isRender)
            if watermarkLayer != nil {
                parentLayer.addSublayer(watermarkLayer!)
            }
        }
        
        return parentLayer;
    }
    
    /**
     * 创建图片通道覆盖物
     */
    func buildPhotoLayer(_ size: CGSize, isRender:Bool) ->CALayer? {
        
        let photoLayer = CALayer();
        photoLayer.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height);
        
        var previousMediaType: PHAssetMediaType = .unknown
        for i in 0 ..< self.timeline.videos.count {
            
            let videoItem = self.timeline.videos[i]
            videoItem.previousMediaType = previousMediaType
            
            if i < self.timeline.videos.count - 1 {
                videoItem.nextMediaType = self.timeline.videos[i + 1].mediaType
            } else {
                videoItem.nextMediaType = .unknown
            }
            
            previousMediaType = videoItem.mediaType
            photoLayer.insertSublayer(videoItem.buildLayer(size, isRender: isRender), at: 0)
        }
        
        return photoLayer;
    }
    
    /** 创建字幕图层 --- 含多个字幕 */
    func buildSubtitleLayer(_ size:CGSize, isRender:Bool) ->CALayer? {
        
        if self.timeline.subtitles == nil {
            return nil;
        }
        
        let titleLayer = CALayer();
        titleLayer.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height);
        
        for compositionLayer:LYSubtitleItem in self.timeline.subtitles! {
            if compositionLayer.enabled {
                titleLayer.addSublayer(compositionLayer.buildLayer(size, isRender: isRender));
            }
        }
        
        return titleLayer;
    }
    
    /** 创建表情图层 --- 含多个表情 */
    func buildStickerLayer(_ size:CGSize) ->CALayer? {
        if self.timeline.stickers == nil {
            return nil;
        }
        
        let stickerLayer = CALayer();
        stickerLayer.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height);
        
        for compositionLayer:LYStickerItem in self.timeline.stickers! {
            if compositionLayer.enabled {
                stickerLayer.addSublayer(compositionLayer.buildLayer(size))
            }
        }
        
        return stickerLayer;
    }
    
    /** 创建表情图层 --- 含多个表情 */
    func buildWatermarkLayer(_ size:CGSize, isRender: Bool) ->CALayer? {
        if self.timeline.watermark == nil {
            return nil;
        }
        
        if watermarkStartTimeline != nil {
            self.timeline.watermark?.startTimeInTimeline = watermarkStartTimeline
            self.timeline.watermark?.timeRange.duration = self.timeline.watermarkDuration
        }
        let titleLayer = CALayer();
        titleLayer.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height);
        
        // 取出最后一帧图片
        //let videoItem = self.timeline.videos.last!
        //let sourceImage = videoItem.phAsset.image(targetSize: size)
        
        // 先添加最后一张图
        if self.timeline.watermark!.enabled {
            titleLayer.addSublayer(self.timeline.watermark!.buildLayer(size, isRender: isRender, blurImage: nil));
        }
        
        return titleLayer;
    }
    
    
}

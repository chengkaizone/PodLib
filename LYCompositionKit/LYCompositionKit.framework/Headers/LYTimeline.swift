//
//  LYTimeline.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import Photos

// track --- 保存的在timeline中的key
// 这个地方设计一定要注意了,有可能词不达意会引起混乱和兼容问题(使用字符串可以解决数值不达意的问题,但是难以兼容oc)
public enum LYTrack: String {
    
    case Video = "Video" // 视频/图片 这里包含了两层, 图片通道在视频通道之上, 贴图/字幕之下
    case Music = "Music" // 音乐
    case Voice = "Voice" // 录音
    case Subtitle = "Subtitle" // 字幕
    case Sticker = "Sticker" // 表情
    case Watermark = "Watermark" //水印
}

public enum EditType: Int {
    case none = -1
    case video = 0
    case image = 1
}

/// 操作选项
public enum OperationOption: Int {
    
    // 无子操作
    case none = -1
    // 裁剪
    case crop = 0
    // 压缩
    case compress = 1
    // 变速 -- 需要参数
    case speed = 2
    // 反转
    case reverse = 3
}

/** 支持序列化的数据结构
 *  包含video,photo
 *  music
 *  voice
 */
open class LYTimeline: NSObject, NSCopying, NSCoding {
    
    /** 类型 0: 影集(仅仅只能选视频), 1: 相册(只能选照片) -1: (不限制) default is 0 */
    open var editType: EditType = .video
    
    /// 操作选项
    open var operationOption: OperationOption = .none

    /**
     * 照片的尺寸限制
     */
    open var limitPreset: String!
    
    /**
     * 占位视频, 在插入图片的地方用到
     * 如果不持久化, 但是每次都需要设置
     */
    open var placeholderVideoURL: URL!
    
    /** 视频片段和图片列表 video, 含视频和图片两种情况 */
    open var videos:[LYVideoItem]

    /** 音乐列表 */
    open var musics:[LYAudioItem]?;
    
    /** 录音列表 */
    open var voices:[LYAudioItem]?;
    
    /** 字幕列表 */
    open var subtitles:[LYSubtitleItem]?;
    
    /** 表情列表 */
    open var stickers:[LYStickerItem]?
    
    /** 水印只有一个 */
    open var watermark:LYWatermarkItem?;
    
    /** 是否启用片尾水印 */
    open var watermarkEnabled: Bool = false
    /** 片尾水印时长 */
    open var watermarkDuration: CMTime = CMTimeMake(value: 2, timescale: 1)
    
    /// 是否启用视频静音 default = false
    open var muteEnabled: Bool = false
    
    /// 是否禁用背景音乐/录音(录音的时候需要关闭所有声音) default = false
    open var audioDisabled: Bool = false
    
    /// 视频音量---视频和音频音量之和为1 default = 0.5
    open var videoVolume: Float = 0.5
    
    // 是否启用视频原音转场过渡(尚有问题,只有最后一个过渡看到效果) default = false 
    open var videoAudioMixTransitionEnabled: Bool = false
    
    open var isDraft:Bool = false;// 是否是草稿
    
    open var draftId:Int64 = 0;// 保存的草稿记录,用户替换草稿归档路径
    
    // 记录草稿路径(归档文件名,目录由上层提供)---重复归档时需要删除之前的归档文件
    open var draftFileName: String?
    
    open var renderSize:CGSize;// 这个属性是创建的过程中自动计算出来的
    open var playbackSize:CGSize;// 预览尺寸 根据渲染尺寸和屏幕尺寸计算出来
    
    // 视频默认帧率
    open var videoTimeScale: Int32 = TIME_SCALE
    
    // 默认允许备份/不参与序列化
    open var backupEnabled: Bool = true
    /// 保留字段, 归档对象老版本可能会不适用于新功能,该字段用于判断
    open var version: Int = 1;
    
    // 是否被编辑, 在自动备份的时候进行判断, 减少性能浪费
    open var isEdited: Bool = false
    
    // 全局滤镜
    open var filter: CIFilter?
    
    override public init() {
        
        renderSize = CGSize(width: 1280, height: 720);
        playbackSize = renderSize;
        videos = [LYVideoItem]();
    }
    
    open func requestItem(_ atTime: TimeInterval) ->LYVideoItem {
        
        return requestItem(CMTime: CMTimeMake(value: Int64(atTime * 1000), timescale: 1000))
    }
    
    /// 请求指定时间点的item
    open func requestItem(CMTime atTime: CMTime) ->LYVideoItem {
        
        for item in self.videos {
            let time = CMTimeGetSeconds(atTime)
            let startTime = CMTimeGetSeconds(item.startTimeInTimeline)
            let endTime = startTime + CMTimeGetSeconds(item.timeRange.duration)
            if time >= startTime && time <= endTime {
                return item
            }
        }
        
        return self.videos[0]
    }
    
    /** 整个时间轴 应用转场 */
    open func applyTransition(_ videoTransition: LYVideoTransition!) {
        
        //var directionInt = 0
        for videoItem in self.videos {
            videoItem.videoTransition = videoTransition.copy() as? LYVideoTransition
            //videoItem.videoTransition?.direction = LYTransitionDirection(rawValue: directionInt % 4)!
            
            //directionInt += 1
        }
    }
    
    /**
     * 设置镜头的背景颜色
     * 设置为nil, 自动使用模糊背景
     */
    open func applyBackgroundColor(_ color: UIColor?) {
        self.clearPhotoImage()
        
        for videoItem in self.videos {
            videoItem.backgroundColor = color
        }
    }
    
    /// 添加视频
    open func appendVideo(_ item:LYVideoItem?) {
        if item == nil {
            return;
        }
        
        item?.prepareAsset()
        
        self.videos.append(item!);
    }
    
    /// 移除指定视频
    open func removeVideo(_ item: LYVideoItem?) {
        if item == nil {
            return
        }
        
        let index = self.videos.firstIndex(of: item!)
        if index != nil {
            self.videos.remove(at: index!)
        }
    }
    
    /// 移除指定索引的镜头
    open func removeVideoFromPosition(_ position: Int) ->Bool {
        if position < 0 || position >= self.videos.count {
            return false
        }
        
        self.videos.remove(at: position)
        return true
    }
    
    /** 拷贝某个位置的镜头 */
    open func copyVideoFromPosition(_ position: Int) ->Bool {
        if position < 0 || position >= self.videos.count {
            return false
        }
        let videoItem = self.videos[position].copy() as! LYVideoItem
        
        self.videos.insert(videoItem, at: position)
        
        return true
    }
    
    /// 交换镜头片段的位置
    open func exchange(_ fromPosition: Int, toPosition: Int) {
        if self.videos.count < fromPosition || self.videos.count < toPosition {
            return
        }
        
        let videoItem = self.videos[fromPosition]
        
        self.videos.remove(at: fromPosition)
        self.videos.insert(videoItem, at: toPosition)
    }
    
    /// 添加音乐
    open func appendMusic(_ item:LYAudioItem?) {
        if item == nil {
            return;
        }
        
        item?.prepareAsset()
        
        if self.musics == nil {
            self.musics = [LYAudioItem]();
        }
        
        self.musics?.append(item!);
    }
    
    /// 移除指定音乐
    open func removeMusic(_ item: LYAudioItem?) {
        if item == nil {
            return
        }
        if self.musics == nil {
            return
        }
     
        let index = self.musics!.firstIndex(of: item!)
        if index != nil {
            self.musics?.remove(at: index!)
        }
    }
    
    // 获取音频排序结果
    open func sortAudios(_ audioItems: [LYAudioItem]?) ->[LYAudioItem]? {
        if audioItems == nil {
            return nil
        }
        
        let resultAudios = audioItems!.sorted(by: { (left, right) -> Bool in
            
            let startLeft = CMTimeGetSeconds(left.startTimeInTimeline)
            let startRight = CMTimeGetSeconds(right.startTimeInTimeline)
            
            return startLeft < startRight
        })
        
        return resultAudios
    }
    
    /** 查询当前音频时间点可到达的下一个时间点  kCMTimeZero:代表可以添加到末尾
     *  audioItem 查询的当前音频
     *  type = 0 query music, type = 1 query voice
     */
    open func queryReachTimeWithAudio(_ audioItem: LYMediaItem, type: Int) ->CMTime {
        
        var tmpAudios = self.musics
        if type == 1 {
            tmpAudios = self.voices
        }
        if tmpAudios == nil {
            return CMTime.zero
        }
        
        tmpAudios = sortAudios(tmpAudios)
        
        var resultTime: CMTime = CMTime.zero
        for item in tmpAudios! {// 一般是不可能在片段中间的,只可能在缝隙间
            if item == audioItem {// 如果查询的是相同的不计算
                continue
            } else {
                // == 0 表示当前点是添加的点
                let result = CMTimeCompare(audioItem.startTimeInTimeline, item.startTimeInTimeline)
                if result == -1 || result == 0 {
                    resultTime = item.startTimeInTimeline
                    break
                }
            }
            
        }
        
        return resultTime
    }
    
    /** 查询当前音乐时间点可到达的下一个时间点  kCMTimeZero:代表可以添加到末尾
     *  currentTime 查询的当前音乐的时间点
     *  type = 0 query music, type = 1 query voice
     */
    open func queryReachTime(_ currentTime: CMTime, type: Int) ->CMTime {
        
        var tmpAudios = self.musics
        if type == 1 {
            tmpAudios = self.voices
        }
        if tmpAudios == nil {
            return CMTime.zero
        }
        
        tmpAudios = sortAudios(tmpAudios)
        
        var resultTime: CMTime = CMTime.zero
        for item in tmpAudios! {// 一般是不可能在片段中间的,只可能在缝隙间
            // == 0 表示当前点是添加的点
            let result = CMTimeCompare(currentTime, item.startTimeInTimeline)
            if result == -1 || result == 0 {
                resultTime = item.startTimeInTimeline
                break
            }
        }
        
        return resultTime
    }
    
    /// 添加录音
    open func appendVoice(_ item:LYAudioItem?) {
        if item == nil {
            return;
        }
        
        item?.prepareAsset()
        
        if self.voices == nil {
            self.voices = [LYAudioItem]();
        }
        
        self.voices?.append(item!);
    }
    
    /// 移除指定的录音
    open func removeVoice(_ item: LYAudioItem?) {
        if item == nil {
            return;
        }
        
        if self.voices == nil {
            return
        }
        
        let index = self.voices!.firstIndex(of: item!)
        if index != nil {
            self.voices?.remove(at: index!)
        }
    }
    
    /// 添加字幕
    open func appendSubtitle(_ item:LYSubtitleItem?) {
        if item == nil {
            return
        }
        
        if self.subtitles == nil {
            self.subtitles = [LYSubtitleItem]()
        }
        
        self.subtitles?.append(item!)
    }
    
    /// 移除指定字幕
    open func removeSubtitle(_ item: LYSubtitleItem?) {
        if item == nil {
            return
        }
        
        if self.subtitles == nil {
            return
        }
        
        let index = self.subtitles!.firstIndex(of: item!)
        if index != nil {
            self.subtitles?.remove(at: index!)
        }
    }
    
    /// 添加贴图
    open func appendSticker(_ item:LYStickerItem?) {
        if item == nil {
            return
        }
        
        if self.stickers == nil {
            self.stickers = [LYStickerItem]()
        }
        
        self.stickers?.append(item!)
    }
    
    /// 移除指定表情
    open func removeSticker(_ item: LYStickerItem?) {
        if item == nil {
            return
        }
        
        if self.stickers == nil {
            return
        }
        
        let index = self.stickers!.firstIndex(of: item!)
        if index != nil {
            self.stickers?.remove(at: index!)
        }
    }
    
    /** 根据全屏模式计算出的尺寸 mode = 0,方块预览 mode = 1 全屏预览 */
    open func calculatePlaybackSizeForMode(_ mode: Int) ->CGSize {
        let size = self.calculateRenderSize();
        
        let screenSize = UIScreen.main.bounds.size;
        
        var resultWidth = screenSize.width;
        var resultHeight = screenSize.width;
        if mode == 1 {// 全屏的话-宽高是反向的
            resultHeight = screenSize.height;
        }
        
        if size.width > size.height {
            
            resultHeight = size.height * resultWidth / size.width;
        }else if size.height > size.width {// 因为预览的高度被限制为相等
            
            resultWidth = size.width * resultHeight / size.height;
        }
        
        return CGSize(width: resultWidth, height: resultHeight);
    }
    
    /** 根据渲染尺寸计算出组件的预览尺寸 */
    open func calculatePlaybackSize(_ renderSize: CGSize) ->CGSize {
        let size = renderSize;
        if size == CGSize.zero {
            return CGSize.zero;
        }
        
        let screenSize = UIScreen.main.bounds.size
        
        var resultWidth = screenSize.width;
        var resultHeight = screenSize.width;
        
        if size.width > size.height {
            
            resultHeight = size.height * resultWidth / size.width;
        }else if size.height > size.width {// 因为预览的高度被限制为相等
            
            resultWidth = size.width * resultHeight / size.height;
        }
        // 去除小数部分误差
        var width = Float(Int(resultWidth * 10)) / 10.0
        var height = Float(Int(resultHeight * 10)) / 10.0
        width = roundf(Float(width))
        height = roundf(Float(height))
        
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
    
    /**
     * 计算渲染尺寸和预览尺寸并赋值给自身 -- 这一步将时基标准化
     * 外部必须手动调用才能正确计算合理尺寸
     */
    open func calculateSizes(){
        
        standardCMTime()
        
        if self.operationOption == .crop {// 只有一个片段
            
            if self.videos.count == 0 {
                return
            }
            
            let videoItem = self.videos[0]
            let renderSize = videoItem.relativeSize(PHOTO_SIZE_HIGH)
            
            self.renderSize = renderSize;
            self.playbackSize = self.calculatePlaybackSize(renderSize);
        } else {
            let renderSize = self.calculateRenderSize();
            
            self.renderSize = renderSize;
            self.playbackSize = self.calculatePlaybackSize(renderSize);
        }
        
        DLog("calculate render size = \(renderSize)");
        DLog("calculate playback size = \(playbackSize)");
    }
    
    /**
     * 根据比率自动计算压缩尺寸
     */
    open func compress(percent: Float) ->Bool {
        
        let renderSize = self.calculateRenderSize()
        
        let value = sqrt(Double(percent))
        var width = Int(Double(renderSize.width) * value)
        var height = Int(Double(renderSize.height) * value)
        
        DLog("compress percent: \(width)  \(height)")
        
        if width % 2 != 0 {
            width = width - 1
        }
        
        if height % 2 != 0 {
            height = height - 1
        }
        
        if width <= 0 || height <= 0 {
            return false
        }
        
        self.renderSize = CGSize(width: width, height: height)
        self.playbackSize = self.calculatePlaybackSize(renderSize)
        
        DLog("calculate render size = \(self.renderSize)");
        DLog("calculate playback size = \(self.playbackSize)");
        
        return true
    }
    
    fileprivate func standardCMTime() {
        
        for videoItem:LYVideoItem in self.videos {
            
            videoItem.timeRange = videoItem.timeRange.standard(self.videoTimeScale)
            videoItem.assetTimeRange = videoItem.assetTimeRange.standard(self.videoTimeScale)
            //DLog("stardardCMTime: \(videoItem.timeRange)   ===   \(videoItem.assetTimeRange)")
        }
    }
    
    /**
     *  自己根据片段的宽高计算出一个预览尺寸
     *  应该根据自己的计算尺寸计算出renderSize
     */
    open func calculateRenderSize() ->CGSize {
        
        var width:CGFloat = CGFloat.infinity;
        var height:CGFloat = CGFloat.infinity;
        
        var squareSize:CGFloat = CGFloat.infinity;
        
        let orientation = calculateOrientation()
        
        let videoCount = self.videos.count
        for videoItem:LYVideoItem in self.videos {
            
            var limitSize = PHOTO_SIZE_HIGH
            
            if self.limitPreset != nil && videoCount > 1 {
                limitSize = CGFloat(LYAssetExportPreset.maxValue(self.limitPreset))
            }
            
            let tmpSize = videoItem.relativeSize(limitSize)
            
            DLog("relative size: \(tmpSize)   \(String(describing: limitPreset))  \(limitSize)")
            
            var naturalSizeWidth = tmpSize.width;
            var naturalSizeHeight = tmpSize.height;
            
            // 因为有些视频可能是多个通道的原因,获取的视频通道宽高为0
            naturalSizeWidth = max(naturalSizeWidth, MIN_RENDER_SIZE);
            naturalSizeHeight = max(naturalSizeHeight, MIN_RENDER_SIZE);
            
            switch orientation {
            case 0:// 竖屏
                width = min(width, naturalSizeWidth);
                height = min(height, naturalSizeHeight);
                break
            case 1:// 横屏
                if videoItem.isRelativeHorizontal() {
                    width = min(width, naturalSizeWidth)
                    height = min(height, naturalSizeHeight)
                }
                break
            case 2:// 方块
                if naturalSizeWidth == naturalSizeHeight {
                    squareSize = min(squareSize, naturalSizeWidth)
                }
                break
            default:
                break
            }
        }
        
        var renderSize = CGSize.zero;
        
        switch orientation {
        case 0:// 竖屏
            if width >= height {// (608.0, 1080.0)
                renderSize = CGSize(width: height, height: width);
            }else{
                renderSize = CGSize(width: width, height: height);
            }
            break
        case 1:// 横屏
            if width >= height {
                renderSize = CGSize(width: width, height: height)
            }else{
                renderSize = CGSize(width: height, height: width);
            }
            break
        case 2:// 方块
            renderSize = CGSize(width: squareSize, height: squareSize)
            break
        default:
            break
        }
        
        return renderSize;
    }
    
    /**
     * 计算绘制方向
     * 0: 竖向 1: 横向  2: 方块
     */
    fileprivate func calculateOrientation() ->Int {
        for videoItem:LYVideoItem in self.videos {
            
            var limitSize = PHOTO_SIZE_HIGH
            if self.limitPreset != nil {
                limitSize = CGFloat(LYAssetExportPreset.maxValue(self.limitPreset))
            }
            let tmpSize = videoItem.relativeSize(limitSize)
            
            var naturalSizeWidth = tmpSize.width;
            var naturalSizeHeight = tmpSize.height;
            
            // 因为有些视频可能是多个通道的原因,获取的视频通道宽高为0
            naturalSizeWidth = max(naturalSizeWidth, MIN_RENDER_SIZE);
            naturalSizeHeight = max(naturalSizeHeight, MIN_RENDER_SIZE);
            
            if naturalSizeWidth == naturalSizeHeight {
                return 2
            }else{
                if videoItem.isRelativeHorizontal() {
                    return 1
                }
            }
        }
        
        return 0
    }
    
    /** 归档成本地文件 --- 一定是document目录下的目录,如果为"",则直接保存到document下 这里只返回文件名 */
    open func saveToFile(dir dirName: String) ->String? {
        
        let docDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString;
        let fileDir = docDir.appendingPathComponent(dirName) as NSString;
        
        let fileManager = FileManager.default;
        if !fileManager.fileExists(atPath: fileDir as String) {
            do {
                try fileManager.createDirectory(atPath: fileDir as String, withIntermediateDirectories: true, attributes: nil);
                
            }catch let error as NSError {
                DLog("saveToFile error: \(error.description)")
                return nil;
            }
            
        }
        
        // 用于查询草稿
        if self.draftId == 0 {// 如果没有保存过---只记录一次
            self.draftId = Int64(Date().timeIntervalSince1970)
        }
        
        var fileName = "\(Int64(Date().timeIntervalSince1970)).archive";
        if self.isDraft && self.draftFileName != nil {
            fileName = self.draftFileName!
        }
        // 保存草稿的归档文件
        self.draftFileName = fileName
        
        let filePath = fileDir.appendingPathComponent(fileName);
        
        // 删除之前的归档文件
        if fileManager.fileExists(atPath: filePath) {
            do {
                DLog("归档路径存在 需要删除: \(filePath)")
                try fileManager.removeItem(atPath: filePath)
            }catch let error as NSError {
                DLog("saveToFile error: \(error.description)")
                return nil;
            }
        }
        
        let result = NSKeyedArchiver.archiveRootObject(self, toFile: filePath);
        if result {
            return fileName;
        }
        
        return nil;
    }
    
    /** 从指定路径恢复timeline */
    open class func restoreFromPath(_ archivePath: String) ->LYTimeline? {
        
        let timeline = NSKeyedUnarchiver.unarchiveObject(withFile: archivePath) as? LYTimeline;
        timeline?.isDraft = true
        timeline?.checkAsset()
        
        return timeline;
    }
    
    /** 
     * 资源检查, 对于被删除的资源, 数据进行清理
     */
    fileprivate func checkAsset() {
        
        // 检查视频
        for videoItem in self.videos {
            
            switch videoItem.locationType {// 相册视频,照片或者pod库音乐 对于非库中的文件统一处理
            case 0:
                if !PHAsset.exist(localIdentifier: videoItem.localIdentifier) {
                    DLog("移除不存在的镜头:  \(String(describing: videoItem.localIdentifier))")
                    self.removeVideo(videoItem)
                }
                break
            case 1, 2:// 内置, 沙盒
                let tmpURL = videoItem.runtimeURL
                let path = tmpURL?.path
                if FileManager.default.fileExists(atPath: path!) == false {
                    DLog("移除不存在的本地沙盒镜头: \(String(describing: path))")
                    self.removeVideo(videoItem)
                }
                break
            default:
                break
            }
            
        }
        
        // 检查配乐
        if self.musics != nil {
            for musicItem in self.musics! {
                
                switch musicItem.locationType {
                case 0:// pod音乐库中
                    if !MPMediaQuery.existAlbums(url: musicItem.url) {
                        DLog("移除不存在的音乐库音乐")
                        self.removeMusic(musicItem)
                    }
                case 1, 2:// 内置, 沙盒(可能被删除的情况)
                    let tmpURL = musicItem.runtimeURL
                    let path = tmpURL?.path
                    if path != nil {
                        if FileManager.default.fileExists(atPath: path!) == false {
                            DLog("移除不存在的本地沙盒音乐: \(String(describing: path))")
                            self.removeMusic(musicItem)
                        }
                    } else {
                        DLog("移除不存在的本地沙盒音乐: \(String(describing: path))")
                        self.removeMusic(musicItem)
                    }
                    
                    break
                default:
                    break
                }
            }
        }
        
        // 检查配音
        if self.voices != nil {
            for voiceItem in self.voices! {
                switch voiceItem.locationType {
                case 0:// pod音乐库中---录音只存在沙盒中
                    break
                case 1, 2:// 内置, 沙盒
                    let tmpURL = voiceItem.runtimeURL
                    let path = tmpURL?.path
                    if FileManager.default.fileExists(atPath: path!) == false {
                        DLog("移除不存在的本地沙盒的配音: \(String(describing: path))")
                        self.removeVoice(voiceItem)
                    }
                    break
                default:
                    break
                }
            }
        }
    }
    
    /**
     * 清空缓存的临时图片缓存/预览-导出图片
     */
    open func clearPhotoImage() {
        self.clearPhotoExportImage()
        self.clearPhotoPreviewImage()
    }
    
    /**
     * 清空缓存的临时图片缓存/预览图片
     */
    open func clearPhotoPreviewImage() {
        // 检查视频
        for videoItem in self.videos {
            if videoItem.mediaType == .image {
                videoItem.photoPreviewImage = nil
            }
        }
    }
    
    /**
     * 清空缓存的临时图片缓存/导出图片
     */
    open func clearPhotoExportImage() {
        // 检查视频
        for videoItem in self.videos {
            if videoItem.mediaType == .image {
                videoItem.photoExportImage = nil
            }
        }
    }
    
    /** 
     * 清理沙盒中的本地文件, 主要是自己创建的视频和录音文件
     *
     */
    open func clearLocalFile() {
        let fileManager = FileManager.default
        for videoItem: LYVideoItem in self.videos {
            // 只需要删除沙盒中的文件
            if videoItem.locationType == 2 {
                do {
                    try fileManager.removeItem(at: videoItem.url as URL)
                    DLog("delete video path: \(videoItem.url.absoluteString)")
                }catch let error as NSError {
                    DLog("delete video path error: \(error.description)")
                }
            }

        }
        
        if self.voices != nil {
            for voiceItem in self.voices! {
                if voiceItem.locationType == 2 {
                    do {
                        try fileManager.removeItem(at: voiceItem.url as URL)
                        DLog("delete voice path: \(voiceItem.url.absoluteString)")
                    }catch let error as NSError {
                        DLog("delete voice path error: \(error.description)")
                    }
                }
            }
        }
    }
    
    /** NSCopying protocol --- 对象深拷贝 */
    open func copy(with zone: NSZone?) -> Any {
        let timeline = LYTimeline()
        timeline.videos = [LYVideoItem]()
        for item:LYVideoItem in self.videos {
            timeline.videos.append(item.copy() as! LYVideoItem)
        }
        if self.musics != nil {
            timeline.musics = [LYAudioItem]()
            for item:LYAudioItem in self.musics! {
                timeline.musics!.append(item.copy() as! LYAudioItem)
            }
        }
        if self.voices != nil {
            timeline.voices = [LYAudioItem]();
            for item:LYAudioItem in self.voices! {
                timeline.voices!.append(item.copy() as! LYAudioItem)
            }
        }
        if self.subtitles != nil {
            timeline.subtitles = [LYSubtitleItem]();
            for item:LYSubtitleItem in self.subtitles! {
                timeline.subtitles!.append(item.copy() as! LYSubtitleItem)
            }
        }
        if self.stickers != nil {
            timeline.stickers = [LYStickerItem]();
            for item:LYStickerItem in self.stickers! {
                timeline.stickers!.append(item.copy() as! LYStickerItem)
            }
        }
        if self.watermark != nil {
            timeline.watermark = self.watermark!.copy() as? LYWatermarkItem
        }
        
        timeline.operationOption = self.operationOption
        timeline.editType = self.editType
        timeline.muteEnabled = self.muteEnabled
        timeline.videoVolume = self.videoVolume
        timeline.videoAudioMixTransitionEnabled = self.videoAudioMixTransitionEnabled
        timeline.isDraft = self.isDraft;
        timeline.draftId = self.draftId;
        timeline.draftFileName = self.draftFileName
        timeline.renderSize = self.renderSize;
        timeline.playbackSize = self.playbackSize
        timeline.version = self.version;
        timeline.placeholderVideoURL = self.placeholderVideoURL
        timeline.limitPreset = self.limitPreset
        
        timeline.backupEnabled = self.backupEnabled
        timeline.isEdited = self.isEdited
        
        timeline.watermarkEnabled = self.watermarkEnabled
        timeline.watermarkDuration = self.watermarkDuration
        timeline.filter = self.filter
        
        return timeline;
    }
    
    /** NSCoding protocol --- 对象归档 */
    open func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.editType.rawValue, forKey: "editType")
        aCoder.encode(self.videos, forKey: "videos");
        aCoder.encode(self.musics, forKey: "musics");
        aCoder.encode(self.voices, forKey: "voices");
        aCoder.encode(self.subtitles, forKey: "subtitles");
        aCoder.encode(self.stickers, forKey: "stickers");
        aCoder.encode(self.watermark, forKey: "watermark");
        
        aCoder.encode(self.muteEnabled, forKey: "muteEnabled");
        aCoder.encode(self.videoVolume, forKey: "videoVolume")
        aCoder.encode(self.videoAudioMixTransitionEnabled, forKey: "videoAudioMixTransitionEnabled")
        aCoder.encode(self.isDraft, forKey: "isDraft");
        aCoder.encode(self.draftId, forKey: "draftId");
        aCoder.encode(self.draftFileName, forKey: "draftFileName")
        aCoder.encode(self.renderSize, forKey: "renderSize");
        aCoder.encode(self.playbackSize, forKey: "playbackSize");
        aCoder.encode(self.version, forKey: "version");
        
        aCoder.encode(self.limitPreset, forKey: "limitPreset")
        aCoder.encode(self.videoTimeScale, forKey: "videoTimeScale")
        aCoder.encode(self.filter, forKey: "filter")
        
        //aCoder.encode(self.watermarkEnabled, forKey: "watermarkEnabled")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        
        let type = aDecoder.decodeInteger(forKey: "editType")
        switch type {
        case 0:
            self.editType = .video
            break
        case 1:
            self.editType = .image
            break
        default:
            self.editType = .none
            break
        }
        self.videos = aDecoder.decodeObject(forKey: "videos") as! [LYVideoItem];
        self.musics = aDecoder.decodeObject(forKey: "musics") as? [LYAudioItem];
        self.voices = aDecoder.decodeObject(forKey: "voices") as? [LYAudioItem];
        self.subtitles = aDecoder.decodeObject(forKey: "subtitles") as? [LYSubtitleItem];
        self.stickers = aDecoder.decodeObject(forKey: "stickers") as? [LYStickerItem];
        // decodeObjectForKey 返回一个autorelease对象, 在调试中会提示有内存泄漏(String类型除外, 因为它是结构体类型)
        self.watermark = aDecoder.decodeObject(forKey: "watermark") as? LYWatermarkItem;
        
        self.muteEnabled = aDecoder.decodeBool(forKey: "muteEnabled")
        self.videoVolume = aDecoder.decodeFloat(forKey: "videoVolume")
        self.videoAudioMixTransitionEnabled = aDecoder.decodeBool(forKey: "videoAudioMixTransitionEnabled")
        self.isDraft = aDecoder.decodeBool(forKey: "isDraft");
        self.draftId = aDecoder.decodeInt64(forKey: "draftId");
        self.draftFileName = aDecoder.decodeObject(forKey: "draftFileName") as? String
        self.renderSize = aDecoder.decodeCGSize(forKey: "renderSize");
        self.playbackSize = aDecoder.decodeCGSize(forKey: "playbackSize");
        self.version = aDecoder.decodeInteger(forKey: "version");

        self.limitPreset = aDecoder.decodeObject(forKey: "limitPreset") as? String
        self.filter = aDecoder.decodeObject(forKey: "filter") as? CIFilter
        let timeScale = aDecoder.decodeInt32(forKey: "videoTimeScale")
        DLog("timescale: \(timeScale)")
        
        if timeScale == 0 {
            self.videoTimeScale = TIME_SCALE
        } else {
            self.videoTimeScale = timeScale
        }
        
        //self.watermarkEnabled = aDecoder.decodeBool(forKey: "watermarkEnabled")
    }
    
    
}

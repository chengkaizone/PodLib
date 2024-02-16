//
//  LYMediaItem.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import Photos

/** 媒体资源 */
open class LYMediaItem: LYTimelineItem {
    
    /// 媒体资源 资源为视频时有效---不参与序列化, 如果是照片, 这个属性为nil
    open var asset:AVAsset! {
        didSet {
            self.prepare()// 这里会花点时间
        }
    }
    
    // 本地相册资源唯一标识符, 可以直接持久化
    open var localIdentifier: String!
    
    // 查询出来的资源 图片类型在片段中都是从相册中取出的 --- 可以获取到相关属性
    open var phAsset: PHAsset!
    
    // 扩展对象, 临时保存的额外数据
    open var extObject: Any!
    
    /// x, y 是矩形相对值, width, height是绝对值
    open var region: CGRect! {
        didSet {
            
            if region.width != 1 {
                // 如果不是偶数, 处理成偶数
                let width = Int(region.width)
                if width % 2 != 0 {
                    region.size.width = CGFloat(width) - 1.0
                }
            }
            
            if region.height != 1 {
                // 如果不是偶数, 处理成偶数
                let height = Int(region.height)
                if height % 2 != 0 {
                    region.size.height = CGFloat(height) - 1.0
                }
            }
            
        }
    }
    
    /// 资源的截取范围  --- 必须显示赋值, 用于视频和音乐, 视频类型时, 用于记录图片的最大可用时长
    open var assetTimeRange: CMTimeRange!
    
    // video/image/audio
    open var mediaType: PHAssetMediaType!
    
    /**
    * 文件位置类型 0: 相册或者pod库, 1: app内置, 2: 沙盒路径
    */
    open var locationType: Int = 0
    
    /// 文件名 使用沙盒视频时有值
    open var filename:String!
    
    /// 在沙盒中的目录 --- locationType = 2时有值
    open var fileDirectory:String!
    
    /// 在内置的bundle文件中 --- locationType = 1时有用,如果为空,代表使用的是mainBundle
    open var bundleName:String!
    
    /// 资源的原始时长 --- 主要用于照片, 视频可以动态获取
    open var assetDuration: CMTime! {
        
        if self.mediaType == .image {
            return self.assetTimeRange.duration
        } else {
            return self.asset.duration
        }
    }
    
    /**
     * 本地相册图片和视频目前使用localIdentifier
     * 传入的asset地址, 照片或者视频, 有可能来自相册,也有可能来自本地
     * 如果是内置,沙盒资源不能直接使用, 是因为应用id升级时一直在变化中
     */
    open var url:URL!
    
    // 运行时url, 用于显示
    open var runtimeURL: URL! {
        get {
            // 在这一步检查资源是否已经不存在了, 不存在就不要创建asset对象 --- 继续处理会crash
            let fileManager = FileManager.default
            switch self.locationType {// 相册视频,照片或者pod库音乐 对于非库中的文件统一处理
            case 0:
                
                return url
            case 1:// 内置

                var bundlePath: String? = Bundle.main.bundlePath
                if bundleName != nil {
                    bundlePath = Bundle.main.path(forResource: bundleName, ofType: "bundle")
                }
                if bundlePath == nil {
                    break
                }
                
                let filePath = bundlePath! + "/".appending(filename)
                
                if fileManager.fileExists(atPath: filePath) {
                    let url = URL(fileURLWithPath: filePath)
                    return url
                }else{
                    DLog("\(self.mediaType!) 资源: \(filePath) 不存在")
                }
                break
            case 2:// 指定路径
                if fileDirectory == nil {
                    break
                }
                let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
                let sanboxDoc = paths[0]
                
                let dir = (sanboxDoc as NSString).appendingPathComponent(fileDirectory!) as NSString;
                let filePath = dir.appendingPathComponent(self.filename)
                if fileManager.fileExists(atPath: filePath) {
                    let url = URL(fileURLWithPath: filePath)
                    return url
                }else{
                    DLog("\(self.mediaType!) \(String(describing: self.filename)) 资源: \(filePath) 不存在")
                }
                
                break
            default:
                break
            }
            
            return nil
        }
    }
    
    /// 标题描述 --- 计算属性不需要参与序列化的拷贝
    fileprivate var title:String? {
        var titleStr:String? = nil;
        for metaItem:AVMetadataItem in self.asset.commonMetadata {
            
            if(metaItem.commonKey == AVMetadataKey.commonKeyTitle){
                titleStr = metaItem.stringValue;
                break;
            }
        }
        
        if titleStr == nil {
            titleStr = self.filename;
        }
        
        return titleStr;
    }
    
    /// 这里因为是动态拷贝在拷贝的时候调用,需要处理nil
    public required convenience init() {
        
        self.init(localIdentifier: nil)
    }
    
    /// 本地相册的情况
    public init(localIdentifier: String!) {
        
        // 拷贝时会调用这个方法, localIdentifier会为空, locationType
        if localIdentifier != nil {
            self.localIdentifier = localIdentifier
            self.locationType = 0
        }
        super.init()
        
        self.setup()
    }
    
    /// 资源时长默认会赋值为不修剪的时长 timeline时长中的播放时长为0
    public init(url: URL!){
        
        // 拷贝时会调用这个方法, url会为空
        if url != nil {
            self.url = url
            self.locationType = 0
        }
        super.init()
        
        self.setup()
    }
    
    // 初始化属性
    fileprivate func setup() {
        // 默认取视频/图片的原始区域
        self.region = CGRect(x: 0, y: 0, width: 1, height: 1)
        self.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: CMTime.zero)
        self.assetTimeRange = CMTimeRangeMake(start: CMTime.zero, duration: CMTime.zero)
    }
    
    /// 同步资源的精确时间
    open func prepare(){
        
        if self.asset == nil {
            return
        }
        
        let _ = self.asset.prepare()
    }
    
    /** 
     * 初始化资源并加载时间, 在不发生拷贝和解档操作时, 加载时间资源需要手动调用该方法
     */
    open func prepareAsset() {
        
        switch self.locationType {// 相册视频,照片或者pod库音乐 对于非库中的文件统一处理
        case 0:
            
            // 这里的音乐和视频要单独处理
            switch self.mediaType! {// 音乐和视频照片统一处理
            case .video:
                self.phAsset = PHAsset.fetchAsset(localIdentifier: self.localIdentifier)
                if self.phAsset == nil {// 防止从归档中恢复时出错
                    DLog("资源: \(String(describing: localIdentifier)) 已经被删除了, 不存在")
                    return
                }
                
                self.asset = self.phAsset.avAsset()
                DLog("this is a video init.")
                break
            case .image:
                self.phAsset = PHAsset.fetchAsset(localIdentifier: self.localIdentifier)
                DLog("this is a image init.")
                break
            case .audio:
                // pod中的音乐如果含有数字版权,是不能获取到url地址, 需要自己导入的音乐才有效
                if MPMediaQuery.existAlbums(url: self.url) {
                    let options = [AVURLAssetPreferPreciseDurationAndTimingKey:true]
                    self.asset = AVURLAsset(url: self.url, options: options)
                }
                
                break
            default:
                break
            }
            
            break
        case 1, 2:// 内置, 沙盒
                        
            let tmpURL = self.runtimeURL
            
            DLog("url: \(String(describing: tmpURL?.path))")
            if tmpURL != nil {
                let options = [AVURLAssetPreferPreciseDurationAndTimingKey:true]
                self.asset = AVURLAsset(url: tmpURL!, options: options)
                
                let _ = asset.tracks(withMediaType: AVMediaType.video)
//                var dimensions = CGSize(width: 960, height: 540)
//                if tracks.count > 0 {
//                    dimensions = tracks[0].naturalSize
//                }
                
            }
            break
        default:
            break
        }
        
    }
    
    /** 创建预览资源 */
    open func makePlayable() ->AVPlayerItem {
        
        return AVPlayerItem(asset: self.asset);
    }
    
    // 解档时需要同步资源
    public required init?(coder aDecoder: NSCoder) {
        self.locationType = aDecoder.decodeInteger(forKey: "locationType")
        self.filename = aDecoder.decodeObject(forKey: "filename") as? String
        self.fileDirectory = aDecoder.decodeObject(forKey: "fileDirectory") as? String
        self.bundleName = aDecoder.decodeObject(forKey: "bundleName") as? String
        
        self.localIdentifier = aDecoder.decodeObject(forKey: "localIdentifier") as? String
        self.url = aDecoder.decodeObject(forKey: "url") as? URL
        
        self.assetTimeRange = aDecoder.decodeTimeRange(forKey: "assetTimeRange")
        self.region = aDecoder.decodeCGRect(forKey: "region")
        
        if self.region == nil {
            
            self.region = CGRect(x: 0, y: 0, width: 1, height: 1)
        } else if self.region == CGRect.zero {
            self.region = CGRect(x: 0, y: 0, width: 1, height: 1)
        }
        
        // 以前的版本是字符串, 会引起错误
        self.mediaType = PHAssetMediaType(rawValue: aDecoder.decodeInteger(forKey: "mediaType"))
        
        super.init(coder: aDecoder)
        
        self.prepareAsset()
    }
    
    // NSCoding 协议
    open override func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.locationType, forKey: "locationType")
        aCoder.encode(self.mediaType.rawValue, forKey: "mediaType")
        aCoder.encode(self.filename, forKey: "filename")
        aCoder.encode(self.fileDirectory, forKey: "fileDirectory")
        aCoder.encode(self.bundleName, forKey: "bundleName")
        
        if let localIdentifier = self.localIdentifier {
            aCoder.encode(localIdentifier, forKey: "localIdentifier")
        }
        
        if let url = self.url {
            aCoder.encode(url, forKey: "url")
        }
        
        if let assetTimeRange = self.assetTimeRange {
            aCoder.encode(assetTimeRange, forKey: "assetTimeRange")
        }
        
        if let regionSize = self.region {
            aCoder.encode(regionSize, forKey: "region")
        }
        
        super.encode(with: aCoder);
    }
    
    override func copyAttrs(_ timelineItem: LYTimelineItem) {
        super.copyAttrs(timelineItem)
        
        let mediaItem = timelineItem as! LYMediaItem;
        
        mediaItem.localIdentifier = self.localIdentifier
        mediaItem.url = self.url
        mediaItem.filename = self.filename
        mediaItem.locationType = self.locationType
        mediaItem.mediaType = self.mediaType
        mediaItem.fileDirectory = self.fileDirectory
        mediaItem.bundleName = self.bundleName
        mediaItem.assetTimeRange = self.assetTimeRange
        mediaItem.region = self.region
        
        mediaItem.prepareAsset()
    }
    
}

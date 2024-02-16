//
//  LYVideoItem.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit
import CoreMedia
import AVFoundation
import CoreGraphics
import Photos

/** 视频媒体或图片片段 */
open class LYVideoItem: LYMediaItem {
    
    open var filter: CIFilter?
    /// 视频转场 --- 用于自身和下一个片段的衔接
    open var videoTransition: LYVideoTransition?
    /// 是否启用单个视频的静音 default = false
    open var muteEnabled: Bool = false
    /// 视频变速参数
    open var timeScale: Double = 1.0
    /**
     * 头部转场时间 为kCMTimeZero代表第一个片段 与tailTransitionTime同为0代表没有转场效果
     * 创建合成通道时赋值
     */
    open var headerTransitionTime: CMTime!
    /// 尾部转场时间
    open var tailTransitionTime: CMTime!
    /// 之前的片段类型 值同mediaType 当值为unknown时代表第一个片段
    var previousMediaType: PHAssetMediaType = .unknown
    /// 下一个片段的类型
    var nextMediaType: PHAssetMediaType = .unknown
    /**
     * 图片背景色, 与模糊背景二选一
     */
    open var backgroundColor: UIColor!
    /** 预览图片 */
    var photoPreviewImage: UIImage!
    /** 导出图片 */
    var photoExportImage: UIImage!
    /////////////////////////// KenBurn动画 ///////////////////////////////
    open var animationDataSource: DefaultAnimationDataSource!
    /** 图片缩放因子 */
    open var scaleFactorDeviation: Float = 1.0
    /** 动画时间 */
    open var animationDuration: Double = 10.0
    /** 动画时长偏差 */
    open var animationDurationDeviation: Double = 0.0
    /**
     * 媒体的相对尺寸--- 不考虑方向
     * 限定尺寸仅对图片类型有效
     */
    open func relativeSize(_ limitSize: CGFloat) ->CGSize {
        if self.mediaType == .video {
            if self.asset == nil {
                return CGSize(width: VIDEO_SIZE_HIGH, height: VIDEO_SIZE_HIGH)
            }
            
            let tracks = self.asset.tracks(withMediaType: AVMediaType.video)
            
            if tracks.count == 0 {
                return CGSize(width: VIDEO_SIZE_HIGH, height: VIDEO_SIZE_HIGH)
            }
            
            let track = tracks[0]
        
            let naturalWidth = track.naturalWidth
            let naturalHeight = track.naturalHeight
            
            DLog("relative 尺寸: \(tracks.count)   \(track.assetAngle())   \(track.naturalSize.width)   \(track.naturalSize.height)  \(naturalWidth)   \(naturalHeight)")
            if region.width == 1 || region.height == 1 {
                return CGSize(width: naturalWidth, height: naturalHeight)
            }
            
            return CGSize(width: region.width, height: region.height)
        } else if self.mediaType == .image {// 这里要控制在限制尺寸内
            
            if phAsset == nil {
                return CGSize(width: limitSize, height: limitSize)
            }
            
            let pixelWidth = CGFloat(phAsset.pixelWidth)
            let pixelHeight = CGFloat(phAsset.pixelHeight)
            
            var size = CGSize(width: pixelWidth, height: pixelHeight)
            
            // 限制图片的尺寸, 有些手机的拍摄尺寸实在是惊人的大, 吃不消呢
            if pixelHeight > pixelWidth {// 竖向拍摄
                if pixelHeight > limitSize {
                    let ratio = pixelHeight / limitSize
                    
                    var width = round(pixelWidth / ratio)
                    
                    if region.width != 1 {
                        width = min(width, region.width)
                    }
                    
                    size = CGSize(width: width, height: limitSize)
                }
            } else {// 横向的情况
                if pixelWidth > limitSize {
                    let ratio = pixelWidth / limitSize
                    
                    var height = pixelHeight / ratio

                    if region.height != 1 {
                        height = min(height, region.height)
                    }
                    
                    size = CGSize(width: limitSize, height: height)
                }
            }
            
            return size
        }
        
        return CGSize.zero
    }
    
    /**
     * 是否横向, 视频的真实方向
     */
    open func isHorizontal() ->Bool {
        
        if self.mediaType == .video {
            return self.asset.isHorizontal()
        } else {
            switch self.locationType {
            case 0:// 相册
                DLog("size: \(phAsset.pixelWidth)   \(phAsset.pixelHeight)")
                if phAsset.pixelWidth > phAsset.pixelHeight {
                    return true
                } else {
                    return false
                }
            case 1:// 内置(目前不存在这种情况)
                break
            case 2:// 沙盒(目前不存在这种情况)
                break
            default:
                break
            }
        }
        
        return false;
    }
    
    /**
     * 是否竖向拍摄
     * 竖拍时width, height需要交换
     */
    func isVertical() -> Bool {
        
        if self.mediaType == .video {
            return self.asset.isVertical()
        } else {
            
            switch self.locationType {
            case 0:// 相册
                if phAsset.pixelWidth < phAsset.pixelHeight {
                    return true
                } else {
                    return false
                }
            case 1:// 内置(目前不存在这种情况)
                break
            case 2:// 沙盒(目前不存在这种情况)
                break
            default:
                break
            }
        }
        
        return false;
    }
    
    /**
     * 是否横向, 仅仅用于计算渲染尺寸, 考虑了宽高因素
     */
    open func isRelativeHorizontal() ->Bool {
        
        if self.mediaType == .video {
            return self.asset.isRelativeHorizontal()
        } else {
            
            switch self.locationType {
            case 0:// 相册
                DLog("size: \(phAsset.pixelWidth)   \(phAsset.pixelHeight)")
                if phAsset.pixelWidth > phAsset.pixelHeight {
                    return true
                } else {
                    return false
                }
            case 1:// 内置(目前不存在这种情况)
                break
            case 2:// 沙盒(目前不存在这种情况)
                break
            default:
                break
            }
        }
        
        return false
    }
    
    /** 
     * 计算出与下一个片段之间合理的转场时间,
     *
     */
    open func calculateTransitionTime(_ videoItem: LYVideoItem!, maxTransitionTime: CMTime) ->CMTime {
        if videoItem == nil {// 最后一个片段的情况
            self.tailTransitionTime = CMTime.zero
            return CMTime.zero
        }
        
        if self.videoTransition == nil {// 没有转场的情况
            self.tailTransitionTime = CMTime.zero
            videoItem.headerTransitionTime = CMTime.zero
            return CMTime.zero
        }
        
        if self.videoTransition!.isKind(of: NoneVideoTransition.self) {
            self.tailTransitionTime = CMTime.zero
            videoItem.headerTransitionTime = CMTime.zero
            return CMTime.zero
        }
        
        var minTime = maxTransitionTime
        switch CMTimeCompare(self.timeRange.duration, videoItem.timeRange.duration) {
        case 1:
            minTime = videoItem.timeRange.duration
            break
        case -1:
            minTime = self.timeRange.duration
            break
        default:
            minTime = self.timeRange.duration
            break
        }
        
        // 视频需要前后参与转场所以只能取资源的一半时长
        var halfMinTime = CMTimeMake(value: minTime.value / 2, timescale: minTime.timescale)
        
        if CMTimeCompare(halfMinTime, maxTransitionTime) == 1 {
            halfMinTime = maxTransitionTime
        }
        
        self.tailTransitionTime = halfMinTime
        videoItem.headerTransitionTime = halfMinTime
        
        return halfMinTime
    }
    
    override public init(localIdentifier: String!) {
        super.init(localIdentifier: localIdentifier)
        
        self.mediaType = .video
        
        self.headerTransitionTime = CMTime.zero
        self.tailTransitionTime = CMTime.zero
    }
    
    override public init(url:URL!){
        super.init(url: url);
        
        self.mediaType = .video
        
        self.headerTransitionTime = CMTime.zero
        self.tailTransitionTime = CMTime.zero
    }
    
    open class func videoItem(_ url:URL) ->LYVideoItem {
        
        return LYVideoItem(url: url);
    }
    
    /** 创建一个空的片段 */
    open class func empty(duration: CMTime) ->LYVideoItem {
        let videoItem = LYVideoItem(url: nil)
        videoItem.mediaType = .unknown
        videoItem.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: duration)
        return videoItem
    }
    
    // 解档
    required public init?(coder aDecoder: NSCoder) {
        // decodeObjectForKey 返回一个autorelease对象, 在调试中会提示有内存泄漏(String类型除外, 因为它是结构体类型)
        // 对象类型属性解档始终都存在泄漏(问题不大)
        self.videoTransition = aDecoder.decodeObject(forKey: "videoTransition") as? LYVideoTransition
        self.muteEnabled = aDecoder.decodeBool(forKey: "muteEnabled")
        self.backgroundColor = aDecoder.decodeObject(forKey: "backgroundColor") as? UIColor
        
        self.timeScale = aDecoder.decodeDouble(forKey: "timeScale")
        self.filter = aDecoder.decodeObject(forKey: "filter") as? CIFilter
        
        super.init(coder: aDecoder)
        
        self.headerTransitionTime = CMTime.zero
        self.tailTransitionTime = CMTime.zero
    }
    
    // NSCoding 协议
    override open func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.videoTransition, forKey: "videoTransition")
        aCoder.encode(self.muteEnabled, forKey: "muteEnabled")
        aCoder.encode(self.backgroundColor, forKey: "backgroundColor")
        aCoder.encode(self.timeScale, forKey: "timeScale")
        aCoder.encode(self.filter, forKey: "filter")
        
        super.encode(with: aCoder);
    }
    
    // 对资源的属性加载 拷贝的情况
    override func copyAttrs(_ timelineItem: LYTimelineItem) {
        super.copyAttrs(timelineItem)
        
        let mediaItem = timelineItem as! LYVideoItem
        mediaItem.videoTransition = self.videoTransition?.copy() as? LYVideoTransition
        mediaItem.muteEnabled = self.muteEnabled
        mediaItem.backgroundColor = self.backgroundColor
        mediaItem.timeScale = self.timeScale
        mediaItem.filter = self.filter
        
        // 动态计算的
        mediaItem.headerTransitionTime = self.headerTransitionTime
        mediaItem.tailTransitionTime = self.tailTransitionTime
    
        mediaItem.photoPreviewImage = self.photoPreviewImage
        mediaItem.photoExportImage = self.photoExportImage
    }
    
    /**
     * 创建layer图层
     * 指定size大小,目前主要是预览和导出两种尺寸
     */
    open func buildLayer(_ size:CGSize, isRender:Bool) ->CALayer {
        
        // 创建含文本和图片的标题图层
        let parentLayer = CALayer();
        parentLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height);
        parentLayer.opacity = 0.0;
        
        if self.mediaType == .image {
            let imageLayer = self.makeImageLayer(size, isRender: isRender);
            parentLayer.addSublayer(imageLayer);
            imageLayer.setAffineTransform(CGAffineTransform.identity);
            
            // 控制显示的时间
            let animation = self.makeAnimation();
            
            // let animationGroup = self.kenBurnsAnimation(size, duration: CMTimeGetSeconds(self.timeRange.duration))
            // animationGroup.animations?.append(animation)
            
            parentLayer.add(animation, forKey: nil);
        
        }
        
        return parentLayer;
    }
    
    func calculateTargetSize(phAsset: PHAsset, size: CGSize, isScale: Bool) ->CGSize {
        
        let pixelWidth = CGFloat(phAsset.pixelWidth)
        let pixelHeight = CGFloat(phAsset.pixelHeight)
        
        let ratioWidth = size.width / pixelWidth
        let ratioHeight = size.height / pixelHeight
        
        var drawWidth = size.width
        var drawHeight = size.height
        
        if ratioWidth < ratioHeight {// 对应宽, 全填充
            drawHeight = pixelHeight * ratioWidth
        } else {
            drawWidth = pixelWidth * ratioHeight
        }
        
        let scale = isScale ? UIScreen.main.scale : 1
        return CGSize(width: drawWidth * scale, height: drawHeight * scale)
    }
    
    
    // MARK: - Helpers
    // 建立图层仿射变换
    private func transformForImageState(imageState: LYImageState) -> CGAffineTransform {
        
        let scaleTransform = CGAffineTransform(scaleX: imageState.scale, y: imageState.scale)
        let translationTransform = CGAffineTransform(translationX: imageState.position.x, y: imageState.position.y)
        let transform = scaleTransform.concatenating(translationTransform)
        return transform
    }
    
    open func makeImageAnimationLayer(_ size: CGSize, isRender: Bool) ->CALayer {
        
        if self.mediaType == .video {
            return CALayer()
        }
        
        if isRender {
        } else {
        }
        if self.animationDataSource == nil {
            let animationDependencies = LYImageAnimationDependencies(scaleFactorDeviation: scaleFactorDeviation, animationDuration: animationDuration, animationDurationDeviation: animationDurationDeviation)
            self.animationDataSource = DefaultAnimationDataSource(animationCalculator: animationDependencies as! LYImageAnimationCalculatorProtocol)
        }
        let targetSize = self.calculateTargetSize(phAsset: phAsset, size: size, isScale: true)
        let _ = self.phAsset.image(targetSize: targetSize)
        //let animation = self.animationDataSource.buildImageAnimation(image: nil, forViewPortSize: CGSize)
        return CALayer()
    }
    
    /**
     * 使用图片指定的尺寸创建layer
     */
    open func makeImageLayer(_ size:CGSize, isRender:Bool) ->CALayer {
        
        if self.mediaType == .video {
            return CALayer()
        }
        
        DLog("makeImageLayer start  \(isRender) \(size)")
        if isRender {// 未设置背景颜色的情况(自动使用模糊背景)
            if self.photoExportImage == nil {
                // 导出时不需要处理密度
                let targetSize = self.calculateTargetSize(phAsset: phAsset, size: size, isScale: false)
                let sourceImage = self.phAsset.image(targetSize: targetSize)
                
                var resultImage: UIImage!
                if sourceImage != nil {
                    // 判断是否是横屏
                    if self.phAsset.isVertical() {
                        DLog("makeImageLayer start  竖屏  \(size)   \(sourceImage!.size)")
                        resultImage = sourceImage!.resize(size, aspectType: 0, fillBackgroundImage: sourceImage!.blurImage())
                    } else {// 横屏也要处理模糊背景, 因为存在横屏尺寸不同的情况
                        DLog("makeImageLayer start  横屏或方块  \(size)   \(sourceImage!.size)")
                        if size == sourceImage!.size {// 尺寸相同不处理模糊
                            DLog("size == 不处理模糊")
                            resultImage = sourceImage!.resize(size, aspectType: 0, fillBackgroundImage: nil)
                        } else {
                            resultImage = sourceImage!.resize(size, aspectType: 0, fillBackgroundImage: sourceImage!.blurImage())
                        }
                    }
                    let width = sourceImage!.size.width
                    let height = sourceImage!.size.height
                    let mem = width * height * 4 / 1024 / 1024
                    DLog("size: \(size) *** src \(width)*\(height) = \(mem) MB  ***** scale image size: \(resultImage.size)")
                }
                self.photoExportImage = resultImage
            }
        } else {
            if self.photoPreviewImage == nil {
                let targetSize = self.calculateTargetSize(phAsset: phAsset, size: size, isScale: true)
                let sourceImage = self.phAsset.image(targetSize: targetSize)
                
                var resultImage: UIImage!
                
                if sourceImage != nil {
                    if self.backgroundColor == nil {
                        // 判断是否是横屏
                        if self.phAsset.isVertical() {
                            DLog("makeImageLayer start  竖屏  \(size)   \(sourceImage!.size)")
                            resultImage = sourceImage!.resize(size, aspectType: 0, fillBackgroundImage: sourceImage!.blurImage())
                        } else {// 横屏不处理模糊背景
                            DLog("makeImageLayer start  横屏或方块  \(size)   \(sourceImage!.size)")
                            if size == sourceImage!.size {// 尺寸相同不处理模糊
                                DLog("size == 不处理模糊")
                                resultImage = sourceImage!.resize(size, aspectType: 0, fillBackgroundImage: nil)
                            } else {
                                resultImage = sourceImage!.resize(size, aspectType: 0, fillBackgroundImage: sourceImage!.blurImage())
                            }
                        }
                    } else {
                        resultImage = sourceImage!.resize(size, aspectType: 0, fillBackgroundImage: nil)
                    }
                    let width = sourceImage!.size.width
                    let height = sourceImage!.size.height
                    let mem = width * height * 4 / 1024 / 1024
                    DLog("size: \(size) *** src \(width)*\(height) = \(mem) MB  ***** scale image size: \(resultImage.size)")
                }
                
                self.photoPreviewImage = resultImage
            }
        }
        
        let imageLayer = CALayer();
        imageLayer.allowsEdgeAntialiasing = true;// 设置边缘抗锯齿
        
        if isRender {
            imageLayer.contents = self.photoExportImage.cgImage
        } else {
            imageLayer.contents = self.photoPreviewImage.cgImage
        }
        
        imageLayer.backgroundColor = self.backgroundColor?.cgColor
        
        // 预览,frame和bounds值效果有一定的区别
        imageLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height);
        
        return imageLayer;
    }
    
    /** 
     * 创建图片显示的时间
     */
    open func makeAnimation() ->CAAnimation {
        
        let keyAnimation = CAKeyframeAnimation(keyPath: "opacity");
        keyAnimation.values = [0.0, 0.0, 1.0, 1.0, 0.0, 0.0];
        
        var headerRatio = CMTimeGetSeconds(headerTransitionTime) / CMTimeGetSeconds(self.timeRange.duration)
        var ratioFadeIn: Float64 = 0
        if self.previousMediaType == .video {// 如果是视频的情况
            ratioFadeIn = headerRatio
        } else if self.previousMediaType == .unknown {// 最后一个片段
            headerRatio = 0
            ratioFadeIn = 0
        }
        // 视频处理为一部分帧 只有最后转场的部分需要处理
        var tailRatio = CMTimeGetSeconds(tailTransitionTime) / CMTimeGetSeconds(self.timeRange.duration)
        var ratioFadeOut: Double = 0
        if self.nextMediaType == .video {
            ratioFadeOut = tailRatio
        } else if self.nextMediaType == .unknown {// 最后一个片段
            tailRatio = 0
            ratioFadeOut = tailRatio
        }
        
        // 这个渐入渐出动画的比例应该是计算出来的,渐入时长一般是1~2秒
    
        keyAnimation.keyTimes = [0.0, NSNumber(value: ratioFadeIn), NSNumber(value: headerRatio), NSNumber(value: 1.0 - tailRatio), NSNumber(value: 1.0 - ratioFadeOut), 1.0];
        
        let beginCMTime = self.startTimeInTimeline == CMTime.invalid ? CMTime.zero : self.startTimeInTimeline;
        let beginTime = CMTimeGetSeconds(beginCMTime!);// 保证不会出现0.0的情况
        keyAnimation.beginTime = beginTime == 0.0 ? AVCoreAnimationBeginTimeAtZero : beginTime;
        keyAnimation.duration = CMTimeGetSeconds(self.timeRange.duration)
        
        keyAnimation.isRemovedOnCompletion = false;// 因为考虑到时基,所以一定不能移除
        
        return keyAnimation;
    }
    
    // 创建动画组
    fileprivate func kenBurnsAnimation(_ size: CGSize, duration: TimeInterval) ->CAAnimationGroup {
        
        let moveAnim = CAKeyframeAnimation(keyPath: "position")
        moveAnim.path = self.trackPath(size).cgPath
        moveAnim.isAdditive = true //Make the values relative to the current value
        moveAnim.isRemovedOnCompletion = false
        
        let ratio = (Double(arc4random()).truncatingRemainder(dividingBy: 10) / 10.0)
        let scale = (CGFloat(ratio) * (TRANSFORM_MAX_SCALE - TRANSFORM_MIN_SCALE)) + TRANSFORM_MIN_SCALE
        
        DLog("scale: \(scale)")
        let transform3D = CATransform3DMakeScale(scale, scale, 1.0)
        
        let scaleAnim = CAKeyframeAnimation(keyPath: "transform")
        scaleAnim.values = [NSValue(caTransform3D: transform3D)]
        scaleAnim.isAdditive = true
        scaleAnim.isRemovedOnCompletion = false
        
        let animGroup = CAAnimationGroup()
        animGroup.animations = [moveAnim, scaleAnim]
        animGroup.beginTime = AVCoreAnimationBeginTimeAtZero
        animGroup.duration = duration
        animGroup.isRemovedOnCompletion = false
        
        return animGroup
    }
    
    /** 创建贝塞尔曲线 */
    fileprivate func trackPath(_ size: CGSize) ->UIBezierPath {
        
        let trackPath = UIBezierPath()
        let startPoint = CGPoint.zero
        let maxDeviation = min(size.width, size.height) * (TRANSFORM_MIN_SCALE - 1)
        trackPath.move(to: startPoint)
        
        // 随机数
        let random = ((CGFloat(arc4random()).truncatingRemainder(dividingBy: 2)) * 2 - 1)
        
        let dx = (CGFloat(arc4random()).truncatingRemainder(dividingBy: maxDeviation)) * random
        let dy = (CGFloat(arc4random()).truncatingRemainder(dividingBy: maxDeviation)) * random
        let endPoint = CGPoint(x: startPoint.x + dx, y: startPoint.y + dy)
        
        DLog("startPoint: \(startPoint)  \(endPoint)")
        trackPath.addLine(to: endPoint)
        
        return trackPath
    }
    
    //MARK: - Private Utilities
    fileprivate func randomBool() -> Bool {
        return arc4random_uniform(100) < 50
    }
    
}

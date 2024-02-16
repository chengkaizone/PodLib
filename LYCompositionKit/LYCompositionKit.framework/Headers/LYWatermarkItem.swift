//
//  LYWatermarkItem.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia

// 水印的尺寸大小和位置是固定的
//private let watermarkSize:CGSize = CGSize(width: 160, height: 160);
// 水印离右下角的边距
private let margin:CGFloat = 20.0;


/**
 * 水印覆盖物---预览的时候不需要,只在导出的时候使用
 * 水印是一直存在的,且一个视频只有一个
 * 一定是在最上层
 * 位置固定在右上角且大小固定
 */
open class LYWatermarkItem: LYTitleItem {
    
    /// 水印一定是内置的图片
    fileprivate var imageName:String;
    fileprivate var title: String!
    
    public init(imageName: String, title: String? = nil) {
        
        self.imageName = imageName;
        self.title = title
        
        super.init();
    }
    
    public required convenience init() {
        
        self.init(imageName: "", title: nil);
    }
    
    /**
     * 创建layer图层
     * 指定size大小,目前主要是预览和导出两种尺寸
     */
    open func buildLayerForCorner(_ size:CGSize) ->CALayer {
        
        // 创建含文本和图片的标题图层
        let parentLayer = CALayer();
        parentLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height);
        parentLayer.opacity = 0.0;
        
        let imageLayer = self.makeImageLayer(size);
        parentLayer.addSublayer(imageLayer);
        
        let position = CGPoint(x: size.width, y: 0);
        
        // 计算成右上角的点
        let newPosition = CGPoint(x: position.x - imageLayer.bounds.width / 2 - margin, y: position.y + imageLayer.bounds.height / 2 + margin);
        
        DLog("position: \(newPosition)")
        imageLayer.position = newPosition;
        
        imageLayer.setAffineTransform(self.transform);
        
        if self.animated {// 设置默认动画
            // 渐入动画
            let fadeInFadeOutAnimation = self.makeAnimation();
            parentLayer.add(fadeInFadeOutAnimation, forKey: nil);
        }
        
        return parentLayer;
    }
    
    /**
     * 创建layer图层
     * 指定size大小,目前主要是预览和导出两种尺寸
     */
    open func buildLayer(_ size: CGSize, isRender: Bool, blurImage: UIImage?) ->CALayer {
        
        // 创建含文本和图片的标题图层
        let parentLayer = CALayer();
        parentLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height);
        parentLayer.opacity = 0.0;
        
        if blurImage != nil { // 添加最后一张模糊背景图
            let blurImageLayer = CALayer();
            blurImageLayer.allowsEdgeAntialiasing = true;// 设置边缘抗锯齿
            blurImageLayer.contents = blurImage?.cgImage;
            blurImageLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            parentLayer.addSublayer(blurImageLayer)
        }
        
        let imageLayer = self.makeImageLayer(size);
        parentLayer.addSublayer(imageLayer);
        
        //let titleLayer = self.makeTitleLayer(size, isRender: isRender)
        //parentLayer.addSublayer(titleLayer)
        
        let position = CGPoint(x: size.width, y: size.height);
        
        // 计算成右上角的点
        //let imagePosition = CGPoint(x: position.x / 2, y: position.y / 2 -  imageLayer.bounds.height / 2)
        let imagePosition = CGPoint(x: position.x / 2, y: position.y / 2)
        
        imageLayer.position = imagePosition;
        
        //let titleY = imagePosition.y + imageLayer.bounds.height / 2 + titleLayer.bounds.height / 2 + 2
        //let titlePosition = CGPoint(x: position.x / 2, y: titleY)
        //titleLayer.position = titlePosition
        
        //DLog("position:==== \(imagePosition)   \(imageLayer.bounds)   \(titlePosition)   \(titleLayer.bounds)")
        
        imageLayer.setAffineTransform(self.transform);
        
        if self.animated {// 设置默认动画
            // 渐入动画
            let fadeInFadeOutAnimation = self.makeAnimation();
            parentLayer.add(fadeInFadeOutAnimation, forKey: nil);
        }
        
        return parentLayer;
    }
    
    /**
     * 创建一直显示的动画
     * 默认情况下是这样
     */
    open func makeAnimation() ->CAAnimation {
        
        let keyAnimation = CAKeyframeAnimation(keyPath: "opacity");
        keyAnimation.values = [1.0, 1.0];
        
        let duration = CMTimeGetSeconds(self.timeRange.duration);
        
        // 这个渐入渐出动画的比例应该是计算出来的,渐入时长一般是1~2秒
        keyAnimation.keyTimes = [0.0, 1.0];
        
        let beginCMTime = self.startTimeInTimeline == CMTime.invalid ? CMTime.zero : self.startTimeInTimeline;
        let beginTime = CMTimeGetSeconds(beginCMTime!);// 保证不会出现0.0的情况
        keyAnimation.beginTime = beginTime == 0.0 ? AVCoreAnimationBeginTimeAtZero : beginTime;
        keyAnimation.duration = duration;
        keyAnimation.calculationMode = CAAnimationCalculationMode.linear
        
        keyAnimation.isRemovedOnCompletion = false;// 因为考虑到时基,所以一定不能移除

        return keyAnimation;
    }
    
    /**
     * 水印一定要传入渲染尺寸,因为只在导出的时候使用
     * 使用指定的尺寸创建layer
     */
    open func makeImageLayer(_ size:CGSize) ->CALayer {
        
        let image = UIImage(named: self.imageName)
        
        let imageLayer = CALayer();
        imageLayer.allowsEdgeAntialiasing = true;// 设置边缘抗锯齿
        
        //let watermarkSize = self.ratioRect.size
        let watermarkSize = size.width > size.height ? size.height : size.width
        let imageWidth = watermarkSize / 3.0
        if image != nil {
            imageLayer.contents = image!.cgImage;
            imageLayer.frame = CGRect(x: 0, y: 0, width: imageWidth, height: imageWidth * 3 / 2);
        }
        
        return imageLayer;
    }
    
    /** 根据预览或者渲染创建文字部分 */
    open func makeTitleLayer(_ size: CGSize, isRender: Bool) ->CALayer {
        
        var fontSize: CGFloat = 20
        if isRender {
            let maxSide = size.width > size.height ? size.width : size.height
            let fontScale = maxSide / UIScreen.main.bounds.width
            fontSize = fontSize * fontScale;
        }
        
        let font = UIFont.boldSystemFont(ofSize: fontSize)
        
        //这里使用富文本来设置字体的颜色
        var attrs: [NSAttributedString.Key:Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: UIColor.white.cgColor];
        
        let string = NSMutableAttributedString(string: self.title, attributes: attrs);
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        string.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, self.title.count))
        
        attrs[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        let textSize = (self.title as NSString).size(withAttributes: attrs);
        
        // anchorPoint 为0.5 应用旋转才正常
        let textLayer = CATextLayer();
        textLayer.isWrapped = true;
        
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.string = string;
        
        textLayer.shadowColor = UIColor.black.cgColor
        textLayer.shadowOffset = CGSize(width: 0.3, height: 0.3)
        
        // anchorPoint, position 都会是中心点
        textLayer.frame = CGRect(x: 0, y: 0, width: textSize.width, height: textSize.height);
        // 解决字体模糊 retina
        textLayer.contentsScale = UIScreen.main.scale
        // 文本不居中??? 系统原因
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        
        DLog("titleSize: \(textSize)")
        
        return textLayer;
    }
    
    // NSCoding 协议
    public required init?(coder aDecoder: NSCoder) {
        
        self.imageName = aDecoder.decodeObject(forKey: "imageName") as! String;
        self.title = aDecoder.decodeObject(forKey: "title") as? String;
        
        super.init(coder: aDecoder);
    }
    
    // NSCoding 协议
    open override func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.imageName, forKey: "imageName");
        aCoder.encode(self.title, forKey: "title");
        
        super.encode(with: aCoder);
    }
    
    override func copyAttrs(_ timelineItem: LYTimelineItem) {
        super.copyAttrs(timelineItem)
        
        let watermarkItem = timelineItem as! LYWatermarkItem;
        
        watermarkItem.imageName = self.imageName;
        watermarkItem.title = self.title
        
    }
    
}

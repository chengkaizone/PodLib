//
//  LYStickerItem.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit
import CoreMedia

/** 表情覆盖物 */
open class LYStickerItem: LYTitleItem {
    
    /// 0-内置, 1-本地路径--注意处理成相对路径,因为沙盒目录是动态变化的
    fileprivate var imageType:Int;
    /// 当imageType = 0 时表示内置 为1时表示本地文件夹 default = 0
    fileprivate var imageName:String;
    /// 表示本地图片文件夹
    fileprivate var imageDirectory:String?
    
    /// 资源包内部文件夹,可以为空
    fileprivate var id:String?
    /// 表示资源包名 imageType = 0时 bundleName为空使用mainBundle资源
    fileprivate var bundleName:String?
    
    /// 图片的缩放比例 default = 1 不缩放
    open var scale: CGFloat = 1
    
    open var path: String? {
        get {
            switch self.imageType {
            case 0:
                var bundlePath: String? = Bundle.main.bundlePath
                if bundleName != nil {
                    bundlePath = Bundle.main.path(forResource: bundleName, ofType: "bundle")
                }
                if bundlePath == nil {
                    return nil
                }
                
                guard let id = id else {
                    return bundlePath! + "/\(imageName)"
                }
                let path = bundlePath! + "/\(id)/\(imageName)"
                return path
            case 1:
                var paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,FileManager.SearchPathDomainMask.userDomainMask, true)
                let sanboxDoc = paths[0] as NSString
                
                guard let directory = imageDirectory else {
                    let filePath = sanboxDoc.appendingPathComponent(self.imageName)
                    return filePath
                }
                
                let dir = sanboxDoc.appendingPathComponent(directory) as NSString;
                let filePath = dir.appendingPathComponent(self.imageName)
                return filePath
            default:
                break
            }
            
            return nil
        }
    }
    
    public init(id: String?, imageType: Int, imageName: String, imageDirectory:String?, bundleName:String?, animated: Bool) {
        self.id = id
        self.imageType = imageType;
        self.imageName = imageName;
        self.imageDirectory = imageDirectory
        self.bundleName = bundleName
        
        super.init()
        
        self.animated = animated
    }
    
    public required convenience init() {
        
        self.init(id: nil, imageType: 0, imageName: "", imageDirectory: nil, bundleName: nil, animated: true);
    }
    
    /**
     * 创建layer图层
     * 指定size大小,目前主要是预览和导出两种尺寸
     */
    open override func buildLayer(_ size:CGSize) ->CALayer {
        
        // 创建含文本和图片的标题图层
        let parentLayer = CALayer();
        parentLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height);
        parentLayer.opacity = 0.0;
        
        let imageLayer = self.makeImageLayer(size);
        parentLayer.addSublayer(imageLayer);
        
        let position = CGPoint(x: self.ratioRect.origin.x * size.width, y: self.ratioRect.origin.y * size.height);
        
        imageLayer.position = position;
        
        imageLayer.setAffineTransform(self.transform);
        
        // 渐入动画
        let fadeInFadeOutAnimation = self.makeFadeInFadeOutAnimation();
        parentLayer.add(fadeInFadeOutAnimation, forKey: nil);
        
        NSLog("Sticker是否有动画：\(animated)")
        if animated {
            // 设置透视
            parentLayer.sublayerTransform = self.makePerspectiveTransform(1000);
            //let spinAnimation = self.make3DSpinAnimation();
            //let offset = spinAnimation.beginTime + spinAnimation.duration - 0.5;
            // 只设置pop动画
            let popAnimation = self.makePopAnimation(0);
            //imageLayer.addAnimation(spinAnimation, forKey: nil);
            imageLayer.add(popAnimation, forKey: nil);
        }
        
        return parentLayer;
    }
    
    /**
     * 使用指定的尺寸创建layer
     */
    open func makeImageLayer(_ size:CGSize) ->CALayer {
        
        guard let path = self.path else {
            return CALayer()
        }
        
        let image = UIImage(contentsOfFile: path)
        
        let imageLayer = CALayer();
        imageLayer.allowsEdgeAntialiasing = true;// 设置边缘抗锯齿
        
        if image != nil {
            imageLayer.contents = image!.cgImage;
            // 预览,frame和bounds值效果有一定的区别
            
            let layerWidth = size.width * self.ratioRect.width
            let layerHeight = layerWidth * self.ratioRect.height
            imageLayer.frame = CGRect(x: 0, y: 0, width: layerWidth, height: layerHeight);
        }
        
        return imageLayer;
    }
    
    // NSCoding 协议
    public required init?(coder aDecoder: NSCoder) {
        
        self.id = aDecoder.decodeObject(forKey: "id") as? String
        self.imageType = aDecoder.decodeInteger(forKey: "imageType")
        self.imageName = aDecoder.decodeObject(forKey: "imageName") as! String;
        self.imageDirectory = aDecoder.decodeObject(forKey: "imageDirectory") as? String
        self.bundleName = aDecoder.decodeObject(forKey: "bundleName") as? String
        self.scale = CGFloat(aDecoder.decodeFloat(forKey: "scale"))
        
        super.init(coder: aDecoder);
    }
    
    // NSCoding 协议
    open override func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.id, forKey: "id");
        aCoder.encode(self.imageType, forKey: "imageType");
        aCoder.encode(self.imageName, forKey: "imageName");
        aCoder.encode(self.imageDirectory, forKey: "imageDirectory")
        aCoder.encode(self.bundleName, forKey: "bundleName")
        aCoder.encode(Float(self.scale), forKey: "scale")

        super.encode(with: aCoder);
    }
    
    override func copyAttrs(_ timelineItem: LYTimelineItem) {
        super.copyAttrs(timelineItem)
        
        let stickerItem = timelineItem as! LYStickerItem;
        
        stickerItem.id = self.id
        stickerItem.imageType = self.imageType;
        stickerItem.imageName = self.imageName;
        stickerItem.imageDirectory = self.imageDirectory
        stickerItem.bundleName = self.bundleName
        stickerItem.scale = self.scale
    }
    
}

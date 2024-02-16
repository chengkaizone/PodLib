//
//  AVMutableVideoCompositionLayerInstruction+AssetTrack.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import AVFoundation

private var LYAssetTrack:UInt = 0;
private var LYRegion: UInt = 1;
public extension AVMutableVideoCompositionLayerInstruction {
    
    /**
     * 定义一个扩展属性,这个属性用于计算矩阵变换
     */
    public var assetTrack:AVAssetTrack? {
        
        get {
            return objc_getAssociatedObject(self, &LYAssetTrack) as? AVAssetTrack;
        }
        
        set(newValue) {
            objc_setAssociatedObject(self, &LYAssetTrack, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }
    
    /**
     * 层指令的显示区域
     */
    public var region: CGRect {
        get {
            guard let value = objc_getAssociatedObject(self, &LYRegion) as? NSValue else {
                return CGRect(x: 0, y: 0, width: 1, height: 1)
            }
            
            let regionSize = value.cgRectValue;
            return regionSize
        }
        
        set(newValue) {
            let value = NSValue(cgRect: newValue);
            objc_setAssociatedObject(self, &LYRegion, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }
    
    /**
     * 配置显示区域
     * 是否裁剪标志
     */
    public func configTransform(_ renderSize: CGSize, _ option: OperationOption) {
        
        if option == .crop {
            let transform = self.calculateCropTransform(renderSize)
            self.setTransform(transform, at: CMTime.zero)
        } else {
            let transform = self.calculateTransform(renderSize)
            self.setTransform(transform, at: CMTime.zero)
        }
        
    }
    
    /**
     * 根据指定的显示区域
     * 计算出需要的矩阵变换
     */
//    public func calculateTransform(renderSize:CGSize) ->CGAffineTransform {
//        let assetTrack = self.assetTrack!;
//        
//        var naturalWidth = assetTrack.naturalSize.width
//        var naturalHeight = assetTrack.naturalSize.height
//        if assetTrack.preferredTransform.isVertical() {// 竖向
//            naturalWidth = assetTrack.naturalSize.height
//            naturalHeight = assetTrack.naturalSize.width
//        }
//        
//        let regionWidth = CGFloat(roundf(Float(naturalWidth * region.size.width)))
//        let regionHeight = CGFloat(roundf(Float(naturalHeight * region.size.height)))
//        
//        DLog("region size: \(renderSize) \(regionWidth)   \(regionHeight)")
//        // 计算出缩放比例
//        var scaleToRatio = renderSize.width / regionWidth;
//        if assetTrack.preferredTransform.isVertical() {// 竖向拍摄需要旋转
//            scaleToRatio = renderSize.height / regionHeight;
//        }else{// 计算横向视频需要缩放比例
//            scaleToRatio = renderSize.width / regionWidth;
//        }
//        //计算缩放因子矩阵
//        let scaleFactorTransform = CGAffineTransformMakeScale(scaleToRatio, scaleToRatio);
//        let tmpTransform = CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactorTransform);
//        
//        var transform = CGAffineTransformIdentity;
//        
//        let offsetX = (assetTrack.naturalSize.width - regionWidth) / 2
//        let offsetY = (assetTrack.naturalSize.height - regionHeight) / 2
//        
//        DLog("offset:  \(assetTrack.naturalSize)  \(offsetX)   \(offsetY)   \(regionWidth)   \(scaleToRatio)  ")
//        
//        transform = CGAffineTransformConcat(tmpTransform, CGAffineTransformMakeTranslation(-offsetX, -offsetY));
//        
//        return transform;
//    }

    /**
     * 计算出需要的矩阵变换
     * 此处为了将镜头居中显示
     */
    public func calculateTransform(_ renderSize:CGSize) ->CGAffineTransform {
        let assetTrack = self.assetTrack!;
        
        // 计算track显示的宽高
        var relativeWidth = assetTrack.naturalWidth
        var relativeHeight = assetTrack.naturalHeight
        if region.width != 1 {
            relativeWidth = region.width
        }
        if region.height != 1 {
            relativeHeight = region.height
        }
        
        let widthFactor = renderSize.width / relativeWidth
        let heightFactor = renderSize.height / relativeHeight
        
        // 放大缩小因子都取最小的情况
        let scaleToRatio: CGFloat = widthFactor <= heightFactor ? widthFactor : heightFactor

        // 自带相机竖拍的视频会有一定的平移
        let tx = assetTrack.preferredTransform.tx * scaleToRatio
        let ty = assetTrack.preferredTransform.ty * scaleToRatio
        let angle = assetTrack.preferredTransform.angle()
        
        DLog("region: \(region) | \(renderSize) | \(relativeWidth) | \(angle) | \(tx) | \(ty)")
        //计算缩放因子矩阵
        let scaleFactorTransform = CGAffineTransform(scaleX: scaleToRatio, y: scaleToRatio)
        let tmpTransform = assetTrack.preferredTransform.concatenating(scaleFactorTransform)

        // 此处已经处理了角度
        let tmpWidth = scaleToRatio * assetTrack.naturalWidth
        let tmpHeight = scaleToRatio * assetTrack.naturalHeight
        
        // 多视频组合计算偏移量
        var offsetX = (renderSize.width - tmpWidth) / 2
        var offsetY = (renderSize.height - tmpHeight) / 2
        
        DLog("tmpWidth: \(renderSize)  \(offsetX)  \(offsetY)")
        
        // assetTrack.preferredTransform.print()
        
        switch angle {
        case 90:// 竖向视频
            if tx == 0 && ty > 0 {
                offsetX += tmpWidth
            } else if tx == 0 && ty == 0 {
                offsetX += tmpWidth
            } else if tx == 0 && ty < 0 {// app前置摄像头反转镜像后 tx = 0 ty < 0
                offsetY += tmpHeight
            }
            break
        case -90:// 竖向视频 ty
            if ty == 0 {
                offsetY += tmpHeight
            }
            break
        case 180:
            
            break
        default:// 0度
            break
        }
        
        DLog("transform: \(angle)   \(scaleToRatio)  \(offsetX)  \(offsetY)")
        let transform = tmpTransform.concatenating(CGAffineTransform(translationX: offsetX, y: offsetY))
        
        return transform
    }
    
    /**
     * 计算出需要的矩阵变换
     * 此处为了将镜头居中显示, 裁剪的方式处理
     */
    public func calculateCropTransform(_ renderSize:CGSize) ->CGAffineTransform {
        
        let assetTrack = self.assetTrack!
        // 此处已经处理了角度
        let tmpWidth = assetTrack.naturalWidth
        let tmpHeight = assetTrack.naturalHeight
        
        var offsetX = -tmpWidth * region.minX
        let offsetY = -tmpHeight * region.minY
        
        let tx = assetTrack.preferredTransform.tx
        let angle = assetTrack.preferredTransform.angle()

        if abs(angle) == 90 && tx == 0 {// 这种情况非标准视频, 需要进行平移
            offsetX += tmpWidth
        }
        
        let transform = assetTrack.preferredTransform.concatenating(CGAffineTransform(translationX: offsetX, y: offsetY))
        
        return transform
    }
    
    public func calculateTransform2(_ renderSize:CGSize) ->CGAffineTransform {
        let assetTrack = self.assetTrack!;
        
        // 计算track显示的宽高
        var relativeWidth = assetTrack.naturalWidth
        var relativeHeight = assetTrack.naturalHeight
        if region.width != 1 {
            relativeWidth = region.width
        }
        if region.height != 1 {
            relativeHeight = region.height
        }
        
        let widthFactor = renderSize.width / relativeWidth
        let heightFactor = renderSize.height / relativeHeight
        
        // 放大缩小因子都取最小的情况
        let scaleToRatio: CGFloat = widthFactor <= heightFactor ? widthFactor : heightFactor
        
        // 自带相机竖拍的视频会有一定的平移
        let tx = assetTrack.preferredTransform.tx * scaleToRatio
        // let ty = assetTrack.preferredTransform.ty * scaleToRatio
        let angle = assetTrack.preferredTransform.angle()
        
        DLog("region: \(region) | \(renderSize) | \(relativeWidth) | \(angle)")
        //计算缩放因子矩阵
        let scaleFactorTransform = CGAffineTransform(scaleX: scaleToRatio, y: scaleToRatio)
        let tmpTransform = assetTrack.preferredTransform.concatenating(scaleFactorTransform)
        
        // 此处已经处理了角度
        let tmpWidth = scaleToRatio * assetTrack.naturalWidth
        let tmpHeight = scaleToRatio * assetTrack.naturalHeight
        
        // 多视频组合计算偏移量
        var offsetX = (renderSize.width - tmpWidth) / 2
        let offsetY = (renderSize.height - tmpHeight) / 2
        
        DLog("tmpWidth: \(renderSize)  \(offsetX)  \(offsetY)")
        
        // assetTrack.preferredTransform.print()
        
        if abs(angle) == 90 && tx == 0 {// 这种情况非标准视频, 需要进行平移
            offsetX += tmpWidth
        }
        
        //        var mixedTransform: CGAffineTransform = CGAffineTransform.identity
        //
        //        switch angle {
        //        case 0:
        //            break
        //        case 90:
        //            // 移动到中心再旋转
        //            let translateToCenter = CGAffineTransform(translationX: tmpHeight, y: 0)
        //            mixedTransform = translateToCenter.concatenating(CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2)))
        //            break
        //        case 180:
        //            let translateToCenter = CGAffineTransform(translationX: tmpWidth, y: tmpHeight)
        //            mixedTransform = translateToCenter.concatenating(CGAffineTransform(rotationAngle: CGFloat(Double.pi)))
        //            break
        //        case 270:
        //            let translateToCenter = CGAffineTransform(translationX: 0, y: tmpWidth)
        //            mixedTransform = translateToCenter.concatenating(CGAffineTransform(rotationAngle: CGFloat(Double.pi * 3 / 2)))
        //            break
        //        default:
        //            break
        //        }
        //        NSLog("transform: \(angle)   \(scaleToRatio)  \(offsetX)   \(offsetY)")
        //        let transform = tmpTransform.concatenating(mixedTransform)
        
        NSLog("transform: \(angle)   \(scaleToRatio)  \(offsetX)   \(offsetY)")
        let transform = tmpTransform.concatenating(CGAffineTransform(translationX: offsetX, y: offsetY))
        
        return transform
    }
    
}

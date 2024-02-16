//
//  UIImageExtension.swift
//  LYCompositionKit
//
//  Created by tony on 2016/11/14.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit

extension UIImage {
    
    /// 是否是竖屏
    func isVertical() ->Bool {
        
        return self.size.height > self.size.width
    }
    
    /**
     * 等比缩放到指定的倍率
     */
    func resizeScale(_ scale: CGFloat) ->UIImage {
        
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        UIGraphicsBeginImageContext(newSize)
        
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let scaleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaleImage!
    }
    
    /** 缩放到刚好显示全图片 */
    func resizeAspect(_ size: CGSize) ->UIImage {
        
        let ratioWidth = size.width / self.size.width
        let ratioHeight = size.height / self.size.height
        
        var newWidth = size.width
        var newHeight = size.height
        if ratioWidth < ratioHeight {// 以高的比例为准进行缩放
            newHeight = self.size.height * ratioWidth
        } else {
            newWidth = self.size.width * ratioHeight
        }
        
        let newSize = CGSize(width: newWidth, height: newHeight)
        UIGraphicsBeginImageContext(newSize)
        
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resultImage!
    }
    
    /**
     * 缩放图片
     * aspectType 是否等比例 0: Aspect 1: AspectFill other: none aspect
     */
    func resize(_ size: CGSize, aspectType: Int, fillBackgroundImage fillImage: UIImage?) ->UIImage {
        
        let ratioWidth = size.width / self.size.width
        let ratioHeight = size.height / self.size.height
        
        var offsetX: CGFloat = 0
        var offsetY: CGFloat = 0
        
        var drawWidth = size.width
        var drawHeight = size.height
        
        switch aspectType {
        case 0:
            if ratioWidth < ratioHeight {// 对应宽, 全填充
                drawHeight = self.size.height * ratioWidth
                offsetY = -(drawHeight - size.height) / 2
            } else {
                drawWidth = self.size.width * ratioHeight
                offsetX = -(drawWidth - size.width) / 2
            }
            break
        case 1:
            if ratioWidth > ratioHeight {// 对应宽, 全填充
                drawHeight = self.size.height * ratioWidth
                offsetY = -(drawHeight - size.height) / 2
            } else {
                drawWidth = self.size.width * ratioHeight
                offsetX = -(drawWidth - size.width) / 2
            }
            break
        default:
            break
        }
        
        UIGraphicsBeginImageContext(CGSize(width: size.width, height: size.height))
        
        if fillImage != nil {
            
            var fillOffsetX: CGFloat = 0
            var fillOffsetY: CGFloat = 0
            
            var fillWidth = size.width
            var fillHeight = size.height
            if ratioWidth > ratioHeight {// 对应宽, 全填充
                fillHeight = self.size.height * ratioWidth
                fillOffsetY = -(fillHeight - size.height) / 2
            } else {
                fillWidth = self.size.width * ratioHeight
                fillOffsetX = -(fillWidth - size.width) / 2
            }
            fillImage?.draw(in: CGRect(x: fillOffsetX, y: fillOffsetY, width: fillWidth, height: fillHeight))
        }
        
        self.draw(in: CGRect(x: offsetX, y: offsetY, width: drawWidth, height: drawHeight))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resultImage!
    }
    
    /**
     * 缩放图片
     * aspectType 是否等比例 0: Aspect 1: AspectFill other: none aspect
     */
    func resize(_ size: CGSize, aspectType: Int, fillColor: UIColor?) ->UIImage {
        
        let ratioWidth = size.width / self.size.width
        let ratioHeight = size.height / self.size.height
        
        var offsetX: CGFloat = 0
        var offsetY: CGFloat = 0
        
        var drawWidth = size.width
        var drawHeight = size.height
        
        switch aspectType {
        case 0:
            if ratioWidth < ratioHeight {// 对应宽, 全填充
                drawHeight = self.size.height * ratioWidth
                offsetY = -(drawHeight - size.height) / 2
            } else {
                drawWidth = self.size.width * ratioHeight
                offsetX = -(drawWidth - size.width) / 2
            }
            break
        case 1:
            if ratioWidth > ratioHeight {// 对应宽, 全填充
                drawHeight = self.size.height * ratioWidth
                offsetY = -(drawHeight - size.height) / 2
            } else {
                drawWidth = self.size.width * ratioHeight
                offsetX = -(drawWidth - size.width) / 2
            }
            break
        default:
            break
        }
        
        UIGraphicsBeginImageContext(CGSize(width: size.width, height: size.height))
        
        if fillColor != nil {
            let context = UIGraphicsGetCurrentContext()
            context?.setFillColor(fillColor!.cgColor)
            context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        
        self.draw(in: CGRect(x: offsetX, y: offsetY, width: drawWidth, height: drawHeight))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resultImage!
    }
    
    func blurImage() ->UIImage {
        let ciContext = CIContext()
        let ciFilter = CIFilter(name: "CIGaussianBlur")
        
        // 这里要使用命名空间
        let sourceImage = CoreImage.CIImage(cgImage: self.cgImage!)
        
        ciFilter?.setValue(sourceImage, forKey: kCIInputImageKey)
        
        let ciImage = ciFilter!.outputImage!
        let cgImage = ciContext.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let blurImage = UIImage(cgImage: cgImage!)
        
        return blurImage
    }
    
    /** 重置图片尺寸 */
    func resizeImage(_ newSize: CGSize, quality: CGInterpolationQuality) ->UIImage {
        
        var drawTransposed = false
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            drawTransposed = true
            break
        default:
            drawTransposed = false
        }
        
        return self.resizeImage(newSize, transform: self.transformForOrientation(newSize), transpose: drawTransposed, quality: quality)
    }
    
    /**
     * 修复图片方向
     */
    func normalizedImage() ->UIImage {
        
        if self.imageOrientation == .up {
            
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage!
    }
    
    func resizeImage(_ newSize: CGSize, transform: CGAffineTransform, transpose: Bool, quality: CGInterpolationQuality) ->UIImage {
        
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral;
        let transposedRect = CGRect(x: 0, y: 0, width: newRect.size.height, height: newRect.size.width);
        let imageRef: CGImage = self.cgImage!;
        
        // Build a context that's the same dimensions as the new size
        let bitmap: CGContext = CGContext(data: nil,
                                          width: Int(newRect.size.width),
                                          height: Int(newRect.size.height),
                                          bitsPerComponent: imageRef.bitsPerComponent,
                                          bytesPerRow: 0,
                                          space: imageRef.colorSpace!,
                                          bitmapInfo: imageRef.bitmapInfo.rawValue)!
        
        // Rotate and/or flip the image if required by its orientation
        bitmap.concatenate(transform);
        
        // Set the quality level to use when rescaling
        bitmap.interpolationQuality = quality;
        
        // Draw into the context; this scales the image
        bitmap.draw(imageRef, in: transpose ? transposedRect : newRect);
        
        // Get the resized image from the context and a UIImage
        let newImageRef = bitmap.makeImage();
        let newImage = UIImage(cgImage: newImageRef!)
        
        return newImage
    }
    
    /// 修复图片方向
    func transformForOrientation(_ newSize: CGSize) ->CGAffineTransform {
        
        var transform = CGAffineTransform.identity
        
        switch self.imageOrientation {
        case .down, .downMirrored:// EXIF 3,4
            transform = transform.translatedBy(x: newSize.width, y: newSize.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            break
        case .left, .leftMirrored:// EXIF 6,5
            transform = transform.translatedBy(x: newSize.width, y: 0)
            transform = transform.rotated(by: CGFloat((Double.pi / 2)))
            break
        case .right, .rightMirrored:// EXIF 8,7
            transform = transform.translatedBy(x: 0, y: newSize.height)
            transform = transform.rotated(by: CGFloat(-(Double.pi / 2)))
            break
        default:
            break
        }
        
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:     // EXIF = 2,4
            transform = transform.translatedBy(x: newSize.width, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
            break;
        case .leftMirrored, .rightMirrored:   // EXIF = 5,7
            transform = transform.translatedBy(x: newSize.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
            break;
        default:
            break
        }
        
        return transform
    }
    
    /** 修复图片方向 */
    func fixOrientation() ->UIImage {
        
        // No-op if the orientation is already correct
        if (self.imageOrientation == UIImage.Orientation.up) {
            return self
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransform.identity;
        
        switch (self.imageOrientation) {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height);
            transform = transform.rotated(by: CGFloat(Double.pi));
            break;
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0);
            transform = transform.rotated(by: CGFloat((Double.pi / 2)));
            break;
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height);
            transform = transform.rotated(by: CGFloat(-(Double.pi / 2)));
            break;
        case .up, .upMirrored:
            break;
        @unknown default:
            break;
        }
        
        switch (self.imageOrientation) {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
            break;
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
            break;
        case .up, .down, .left, .right:
            break;
        @unknown default:
           break;
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height),
                            bitsPerComponent: (self.cgImage?.bitsPerComponent)!, bytesPerRow: 0,
                            space: (self.cgImage?.colorSpace!)!,
                            bitmapInfo: (self.cgImage?.bitmapInfo.rawValue)!);
        ctx?.concatenate(transform);
        switch (self.imageOrientation) {
        case .left, .leftMirrored, .right, .rightMirrored:
            // Grr...
            ctx?.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.height,height: self.size.width));
            break;
            
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.width,height: self.size.height));
            break;
        }
        
        // And now we just create a new UIImage from the drawing context
        guard let cgimg = ctx?.makeImage() else {
            return self
        }
        
        let img = UIImage(cgImage: cgimg)
        
        return img;
    }
    
}

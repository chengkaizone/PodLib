//
//  LYPreviewView.swift
//  CameraFilter
//
//  Created by tony on 2017/6/7.
//  Copyright © 2017年 chengkaizone. All rights reserved.
//

import UIKit
import GLKit

/// 使用OpenGL 视图渲染(GPU)
public class LYPreviewView: GLKView {
    
    var filter: CIFilter!
    var coreImageContext: CIContext!
    
    // 绘制的区域
    var drawableBounds: CGRect!
    
    var isTransform: Bool = false
    
    var tapFocusGesture: UITapGestureRecognizer!
    
    public override init(frame: CGRect, context: EAGLContext) {
        super.init(frame: frame, context: context)
        
        NotificationCenter.default.addObserver(self, selector: #selector(filterChanged(_:)), name: NSNotification.Name(rawValue: LYPhotoFilter.FilterSelectedChangedNotification), object: nil)
        
        self.enableSetNeedsDisplay = false
        self.backgroundColor = UIColor.black
        self.isOpaque = true
        
        self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        self.frame = frame // 执行矩阵后需要重新设置位置
        
        setup()
    }
    
    public override var frame: CGRect {
        didSet {
            
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        setup()
        
        NSLog("bounds: \(bounds)")
    }
    
    private func setup() {
        // 绑定帧缓冲, 这一步之后可以获取到绘制的宽,高
        self.bindDrawable()
        
        self.drawableBounds = self.bounds
        // 此处的宽高非像素点
        drawableBounds.size.width = CGFloat(self.drawableWidth)
        drawableBounds.size.height = CGFloat(self.drawableHeight)
        
        isTransform = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func filterChanged(_ notification: Notification) {
        
        self.filter = notification.object as? CIFilter
    }
    
}

fileprivate extension CGRect {
    
    /// 将当前边界根据预览视图区域从中间裁剪
    func centerCropImageRect(previewRect: CGRect) ->CGRect {
        
        let sourceAspectRatio = self.width / self.height
        let previewAspectRatio = previewRect.width / previewRect.height
        
        var drawRect = self
        if sourceAspectRatio > previewAspectRatio {
            
            let scaledHeight = drawRect.height * previewAspectRatio
            drawRect.origin.x += (drawRect.width - scaledHeight) / 2.0
            drawRect.size.width = scaledHeight
        } else {
            drawRect.origin.y += (drawRect.height - drawRect.width / previewAspectRatio) / 2.0
            drawRect.size.height = drawRect.width / previewAspectRatio
        }
        
        return drawRect
    }
    
}

extension LYPreviewView: LYImageTarget {
    
    public func setImage(ciImage sourceImage: CIImage) {
        
        self.bindDrawable()
        
        if self.filter != nil {
            //DLog("output size: \(sourceImage.extent)   drawableBounds: \(drawableBounds)")
            self.filter.setValue(sourceImage, forKey: kCIInputImageKey)
            
            if let filteredImage = self.filter.outputImage {
                
                //DLog("sourceImage size: \(sourceImage.extent.width)   \(sourceImage.extent.height)")
                // 仅仅绘制中间区域
                var cropRect = sourceImage.extent.centerCropImageRect(previewRect: self.drawableBounds)
                
                cropRect.origin = CGPoint.zero
                //DLog("cropRect : \(cropRect)   \(self.drawableBounds)")
                
                self.coreImageContext.draw(filteredImage, in: self.drawableBounds, from: cropRect)
            }
        } else {
            var cropRect = sourceImage.extent.centerCropImageRect(previewRect: self.drawableBounds)
            cropRect.origin = CGPoint.zero
            
            self.coreImageContext.draw(sourceImage, in: self.drawableBounds, from: cropRect)
        }
        
        self.display()
        
        self.filter?.setValue(nil, forKey: kCIInputImageKey)
    }
    
}


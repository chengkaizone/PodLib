//
//  CGRectExtension.swift
//  LYCompositionKit
//
//  Created by tony on 2017/7/8.
//  Copyright © 2017年 chengkai. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

extension CGRect {
    
    init(center: CGPoint, size: CGSize) {
        self = CGRect(x: center.x - (size.width / 2), y: center.y - (size.height / 2), width: size.width, height: size.height)
    }
    
    /// 将当前边界根据预览视图区域从中间裁剪
    func centerCrop(previewRect: CGRect) ->CGRect {
        
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
    
    func scaledRect(scale: CGFloat) -> CGRect {
        return CGRect(x: self.minX * scale,
                      y: self.minY * scale,
                      width: self.width * scale,
                      height: self.height * scale)
    }
    
    func center() -> CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
    
}

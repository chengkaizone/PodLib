//
//  LYTextLayer.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit

/** 使文本绘制居中 */
class LYTextLayer: CATextLayer {
    
    var strings: AnyObject?
    var stringAttributes: [NSAttributedString.Key : Any]?
    
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        
        ctx.setFillColor(UIColor.clear.cgColor)
        UIGraphicsPushContext(ctx)
        
        strings?.draw(at: CGPoint.zero, withAttributes: stringAttributes)
        
        UIGraphicsPopContext()
    }
    
}

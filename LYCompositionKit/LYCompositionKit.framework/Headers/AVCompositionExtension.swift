//
//  AVCompositionExtension.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import AVFoundation

private var LYRenderSize:UInt = 0
extension AVComposition {
    
    /** 定义一个扩展属性 */
    public var renderSize:CGSize {// 必须先存储---不然后果未知
        
        get {
            let value = objc_getAssociatedObject(self, &LYRenderSize) as! NSValue;
            let size = value.cgSizeValue;
            return size;
        }
        
        set(newValue) {
            
            let value = NSValue(cgSize: newValue);
            objc_setAssociatedObject(self, &LYRenderSize, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }
    
}

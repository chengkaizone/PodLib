//
//  UIViewExtension.swift
//  LYCompositionKit
//
//  Created by tony on 2016/11/14.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit

fileprivate var holderKeySave: UInt = 0;
fileprivate var recognizerScale: CGFloat = 0
public extension UIView {
    
    // 声明一个扩展标题,用于保存正标题
    var scaleRatio: CGFloat {
        
        get {
            guard let number = objc_getAssociatedObject(self, &recognizerScale) as? NSNumber else {
                return 1.0
            }
            
            return CGFloat(number.floatValue)
        }
        
        set {
            objc_setAssociatedObject(self, &recognizerScale, scaleRatio, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.transform = CGAffineTransform(scaleX: scaleRatio, y: scaleRatio)
        }
    }
    
    // 资源的时间范围, 用于绑定图片控件对应的key
    var holderKey: String? {
        
        get {
            // 转化回来
            let value = objc_getAssociatedObject(self, &holderKeySave)
            return value as! String?
        }
        
        set {
            if let newValue = newValue {
                
                objc_setAssociatedObject(self, &holderKeySave, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
}

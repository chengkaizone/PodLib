//
//  CGAffineTransform+Rotation.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import Foundation
import UIKit

extension CGAffineTransform {
    
    func print() {
        
        NSLog("CGAffineTransform params: \(a) | \(b) | \(c) | \(d) | \(tx) | \(ty)")
    }
    
    // 判断矩阵的旋转角度
    func angle() ->Int {
        // .portrait, Home键在下方
        if (self.a == 0 && self.b == 1.0 && self.c == -1.0 && self.d == 0) {
            return 90;// 竖着拍
        }
        // .portraitUpsideDown, Home键在上方
        if (self.a == 0 && self.b == -1.0 && self.c == 1.0 && self.d == 0) {
            return -90;// 倒竖着拍
        }
        // .landscapeRight, Home键在左方 前置摄像头在右方
        if (self.a == 1.0 && self.b == 0 && self.c == 0 && self.d == 1.0) {
            return 0;// 顶部向左横拍
        }
        // .landscapeLeft, Home键在右方 前置摄像头在右方
        if (self.a == -1.0 && self.b == 0 && self.c == 0 && self.d == -1.0) {
            return 180;// 顶部向右横拍
        }
        
        return 90
    }
    
    // 判断矩阵的旋转角度
    func orientation() ->UIInterfaceOrientation {
        // .portrait, Home键在下方
        if (self.a == 0 && self.b == 1.0 && self.c == -1.0 && self.d == 0) {
            return .portrait // 竖着拍
        }
        // .portraitUpsideDown, Home键在上方
        if (self.a == 0 && self.b == -1.0 && self.c == 1.0 && self.d == 0) {
            return .portraitUpsideDown// 倒竖着拍
        }
        // .landscapeRight, Home键在左方
        if (self.a == 1.0 && self.b == 0 && self.c == 0 && self.d == 1.0) {
            return .landscapeRight // 顶部向左横拍
        }
        // .landscapeLeft, Home键在右方
        if (self.a == -1.0 && self.b == 0 && self.c == 0 && self.d == -1.0) {
            return .landscapeLeft // 顶部向右横拍
        }
        
        return .portrait
    }
    
    /** 
     * 是否竖向拍摄
     * 竖拍时width, height需要交换
     */
    func isVertical() -> Bool {
        
        let relativeAngle = self.angle() % 180;
        if relativeAngle == 90 || relativeAngle == -90 {// 竖向拍摄需要旋转
            return true;
        }
        
        return false;
    }
    
    static func transform(orientation: UIDeviceOrientation) ->CGAffineTransform {
        
        var result: CGAffineTransform!
        
        switch orientation {
        case .landscapeRight:
            result = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            break
        case .portraitUpsideDown:
            result = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2 * 3))
            break
        case .portrait, .faceUp, .faceDown:
            result = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
            break
        default:
            result = CGAffineTransform.identity
            break
        }
        
        return result
    }
    
}

//
//  UIColorExtension.swift
//  LineVideo
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkaizone. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    public convenience init(colorHex: UInt32, alpha: CGFloat = 1.0) {
        
        let red     = CGFloat((colorHex & 0xFF0000) >> 16) / 255.0
        let green   = CGFloat((colorHex & 0x00FF00) >> 8 ) / 255.0
        let blue    = CGFloat((colorHex & 0x0000FF)      ) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// 动态颜色
   /// - Parameter light: 正常模式颜色
   /// - Parameter dark: 暗黑模式
   public static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
       if #available(iOS 13.0, *) {
           return UIColor { (traitCollection: UITraitCollection) -> UIColor in
               if traitCollection.userInterfaceStyle == UIUserInterfaceStyle.light {
                   return light
               } else {
                   return dark
               }
           }
       }
       return light
   }
        
        
        /// 使用字符串颜色
        /// - Parameter light: 正常模式颜色
        /// - Parameter dark: 暗黑模式颜色
        public static func argb(light: String, dark: String) -> UIColor {
            if #available(iOS 13.0, *) {
                return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                    if traitCollection.userInterfaceStyle == UIUserInterfaceStyle.light {
                        return UIColor(argb: light)
                    } else {
                        return UIColor(argb: dark)
                    }
                }
            }
            return UIColor(argb: light)
        }
    
    /** 重置alpha值 */
    public func resetAlpha(alpha value: CGFloat) ->UIColor {
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        var alphaValue: CGFloat = value
        if value < 0 {
            alphaValue = 0
        } else if value > 1 {
            alphaValue = 1
        }
        
        return UIColor(red: red, green: green, blue: blue, alpha: alphaValue)
    }
    
    public static var randomColor: UIColor {
        return UIColor(red: CGFloat(arc4random_uniform(256))/255.0, green: CGFloat(arc4random_uniform(256))/255.0, blue: CGFloat(arc4random_uniform(256))/255.0, alpha: 1.0)
    }
    
    /** 返回无alpha通道的颜色值 */
    public func rgbColor() -> UIColor {
        
        return resetAlpha(alpha: 1)
    }
    
    /** 获取alpha值 */
    public func alpha() -> CGFloat {
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return alpha
    }
    
    /// 初始化颜色
    /// - Parameter argb: ragb颜色格式
    public convenience init(argb: String) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 1.0
        if(argb.hasPrefix("#")){
            let index = argb.index(argb.startIndex, offsetBy: 1)
            let hex = String(argb[index...])
            let scanner = Scanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if(scanner.scanHexInt64(&hexValue)){
                switch(hex.count){
                case 3:
                    red = CGFloat((hexValue & 0xF00) >> 8)/15.0
                    green = CGFloat((hexValue & 0x0F0) >> 4)/15.0
                    blue = CGFloat(hexValue & 0x00F) / 15.0
                case 6:
                    red = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
                    blue = CGFloat(hexValue & 0x0000FF) / 255.0
                case 4:
                    alpha = CGFloat((hexValue & 0xF000) >> 12) / 15.0
                    red = CGFloat((hexValue & 0x0F00) >> 8) / 15.0
                    green = CGFloat((hexValue & 0x00F0) >> 4) / 15.0
                    blue = CGFloat(hexValue & 0x000F) / 15.0
                case 8:
                    alpha = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    red = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    green = CGFloat((hexValue & 0x0000FF00) >> 8) / 255.0
                    blue = CGFloat(hexValue & 0x000000FF) / 255.0
                default:
                    DLog("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8");
                }
            } else {
                DLog("Scan hex error")
            }
        } else {
            DLog("Invalid RGB string, missing '#' as prefix")
        }
        //调用指定构造器,如果不调用指定构造器是无法通过编译的
        self.init(red: red, green: green, blue: blue, alpha: alpha);
    }
    
    /** 使用16进制字符串创建颜色 以#开头
     声明便利构造器,必须调用指定构造器
     - parameter rgba: rgba description
     - returns: return value description
     */
//    public convenience init(rgba:String) {
//        var red:CGFloat = 0.0;
//        var green:CGFloat = 0.0;
//        var blue:CGFloat = 0.0;
//        var alpha: CGFloat = 1.0;
//        if(rgba.hasPrefix("#")){
//            let index = rgba.index(rgba.startIndex, offsetBy: 1)
//            let hex = String(rgba[index...])
//            let scanner = Scanner(string: hex);
//            var hexValue:CUnsignedLongLong = 0;
//            if(scanner.scanHexInt64(&hexValue)){
//                switch(hex.count){
//                case 3:
//                    red = CGFloat((hexValue & 0xF00) >> 8)/15.0;
//                    green = CGFloat((hexValue & 0x0F0) >> 4)/15.0;
//                    blue = CGFloat(hexValue & 0x00F) / 15.0;
//                case 4:
//                    red = CGFloat((hexValue & 0xF000) >> 12) / 15.0
//                    green = CGFloat((hexValue & 0x0F00) >> 8) / 15.0
//                    blue = CGFloat((hexValue & 0x00F0) >> 4) / 15.0
//                    alpha = CGFloat(hexValue & 0x000F) / 15.0
//                case 6:
//                    red = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
//                    green = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
//                    blue = CGFloat(hexValue & 0x0000FF) / 255.0
//                case 8:
//                    red = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
//                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
//                    blue = CGFloat((hexValue & 0x0000FF00) >> 8) / 255.0
//                    alpha = CGFloat(hexValue & 0x000000FF) / 255.0
//                default:
//                    DLog("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8");
//                }
//            }else{
//                DLog("Scan hex error")
//            }
//        }else{
//            DLog("Invalid RGB string, missing '#' as prefix")
//        }
//        //调用指定构造器,如果不调用指定构造器是无法通过编译的
//        self.init(red:red, green:green, blue:blue, alpha:alpha);
//    }
//
    // 图片代表的纯色位图
    func bitmap(_ size: CGSize = CGSize(width: 1, height: 1)) ->UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        // 开启位图上下文
        UIGraphicsBeginImageContext(rect.size)
        // 获取位图上下文
        let context = UIGraphicsGetCurrentContext()
        // 使用color演示填充上下文
        context?.setFillColor(self.cgColor)
        // 渲染上下文
        context?.fill(rect)
        // 从上下文中获取图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        // 结束上下文
        UIGraphicsEndImageContext()
        
        return image!
    }

    // 图片代表的纯色位图
    func bitmap(size: CGSize = CGSize(width: 1, height: 1), radius: CGFloat, resizable: Bool = false) ->UIImage {
        let tmpImage = self.bitmap(size)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        UIBezierPath(roundedRect: rect, cornerRadius: radius).addClip()
        tmpImage.draw(in: rect)
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if resizable {
            let insets = UIEdgeInsets.init(top: radius, left: radius, bottom: radius, right: radius)
            image = image?.resizableImage(withCapInsets: insets, resizingMode: .stretch)
        }
        return image!
    }
    
}


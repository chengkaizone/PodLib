//
//  NumberKeyboardSdk.swift
//  LineCal
//
//  Created by tony on 2024/2/15.
//  Copyright © 2024 chengkaizone. All rights reserved.
//

import UIKit

/// 键盘对外接口
public class NumberKeyboardSdk {
    
    static var mBusinessImpl: INumberKeyboardBusiness?
    
    public class func initialize(businessImpl : INumberKeyboardBusiness) {
        
        NumberKeyboardSdk.mBusinessImpl = businessImpl
    }
    
    /// 获取默认return键文本
    /// - Returns:
    class func defaultReturnKeyTitle() -> String {
        return NumberKeyboardSdk.mBusinessImpl?.defaultReturnKeyTitle() ?? ""
    }
    
    /**
     * 获取主题颜色
     */
    class func getThemeColor() -> UIColor {
        if NumberKeyboardSdk.mBusinessImpl == nil {
            return UIColor(_colorLiteralRed: 0, green: 0x9f / 256.0, blue: 0xf7 / 256.0, alpha: 1)
        }
        return NumberKeyboardSdk.mBusinessImpl!.getThemeColor()
    }
    
    
    /// 是否中文语境
    /// - Returns:
    class func isZhCN() -> Bool {
        return NumberKeyboardSdk.mBusinessImpl?.isZhCN() ?? false
    }
    
    class func impact() {
        NumberKeyboardSdk.mBusinessImpl?.impact()
    }
    
    class func impactFeedbackEnabled() -> Bool {
        return NumberKeyboardSdk.mBusinessImpl?.impactFeedbackEnabled() ?? true
    }
    
    /// 获取播报类型
    /// - Returns: 0: 简单音效 1: 声音播报 2: 静音
    class func getVoiceEffectType() -> Int {
        return NumberKeyboardSdk.mBusinessImpl?.getVoiceEffectType() ?? 0
    }
    
    class func playSound() {
        NumberKeyboardSdk.mBusinessImpl?.playSound()
    }
    
    class func speakText(text: String) {
        NumberKeyboardSdk.mBusinessImpl?.speakText(text: text)
    }
    
    class func keyAdd() -> String {
        return NumberKeyboardSdk.mBusinessImpl?.keyAdd() ?? ""
    }
    
    class func keyReduce() -> String {
        return NumberKeyboardSdk.mBusinessImpl?.keyReduce() ?? ""
    }
    
    class func keyMultiply() -> String {
        return NumberKeyboardSdk.mBusinessImpl?.keyMultiply() ?? ""
    }
    
    class func keyDivide() -> String {
        return NumberKeyboardSdk.mBusinessImpl?.keyDivide() ?? ""
    }
    
    class func keyEq() -> String {
        return NumberKeyboardSdk.mBusinessImpl?.keyEq() ?? ""
    }
    
}

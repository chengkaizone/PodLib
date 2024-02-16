//
//  INumberKeyboardBusiness.swift
//  LineCal
//
//  Created by tony on 2024/2/15.
//  Copyright © 2024 chengkaizone. All rights reserved.
//

import UIKit

/// 键盘业务层协议
public protocol INumberKeyboardBusiness {
    
    /// 获取主题色
    /// - Returns:
    func getThemeColor() -> UIColor
    
    /// 是否中文语境
    /// - Returns:
    func isZhCN() -> Bool
    
    /// 按键反馈
    func impact()
    
    /// 是否启用按键反馈
    func impactFeedbackEnabled() -> Bool
    
    /// 获取默认return键文本
    /// - Returns: 
    func defaultReturnKeyTitle() -> String
    
    /// 获取播报类型
    /// - Returns: 0: 简单音效 1: 声音播报 2: 静音
    func getVoiceEffectType() -> Int
    
    /// 播放按键音效
    func playSound()
    
    /// 播报文本
    /// - Parameter text:
    func speakText(text: String)
    
    /// 按键+播报文本
    /// - Returns:
    func keyAdd() -> String
    
    /// 按键-播报文本
    /// - Returns:
    func keyReduce() -> String
    
    /// 按键x播报文本
    /// - Returns:
    func keyMultiply() -> String
    
    /// 按键÷播报文本
    /// - Returns:
    func keyDivide() -> String
    
    /// 按键=播报文本
    /// - Returns:
    func keyEq() -> String
    
    
}

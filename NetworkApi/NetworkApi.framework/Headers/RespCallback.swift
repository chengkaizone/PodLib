//
//  RespCallback.swift
//  LineCal
//
//  Created by tony on 2023/7/9.
//  Copyright © 2023 chengkaizone. All rights reserved.
//

import Foundation

public protocol RespCallback {
    
    
    /// 回调接口返回结果
    /// - Parameter result: 返回字符串
    /// - Parameter error: 错误信息
    func onCallback(result: String, error: Error?)

    
}

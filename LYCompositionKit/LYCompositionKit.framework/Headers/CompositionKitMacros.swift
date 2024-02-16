//
//  CompositionKitMacros.swift
//  LYCompositionKit
//
//  Created by tony on 16/5/2.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import Foundation

// let DEBUG: Bool = true
// MARK: - 在 Relase 模式下，关闭后台打印
func DLog(_ format: String, _ args: CVarArg...) {
    
    #if DEBUG
        NSLog(String(format: format, arguments: args))
    #else
        
    #endif
    
//    if DEBUG {
//        NSLog(String(format: format, arguments: args))
//    }

}

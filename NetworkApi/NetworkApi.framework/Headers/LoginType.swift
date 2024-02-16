//
//  LoginType.swift
//  LineCal
//
//  Created by tony on 2024/2/2.
//  Copyright © 2024 chengkaizone. All rights reserved.
//

import Foundation

public enum LoginType : Int {
    // 用户密码登录（默认）
    case USERNAME = 0
    // 邮箱密码登录
    case EMAIL = 1
    // token登录
    case TOKEN = 2
    // Apple登录
    case APPLE = 3
    // 微信登录
    case WECHAT = 4
    
}

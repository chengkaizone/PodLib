//
//  ErrorCode.swift
//  LineCal
//
//  Created by tony on 2024/2/4.
//  Copyright © 2024 chengkaizone. All rights reserved.
//

import Foundation

/// 后端错误码定义
public enum ErrorCode : Int {
    // 邮箱没有注册
    case EMAIL_NOT_REGISTER = 10001
    // 手机号没有注册
    case PHONE_NOT_REGISTER = 10002
    // 修改密码失败
    case MOD_PASSWORD_FAILED = 10003
}

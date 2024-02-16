//
//  HttpApi.swift
//  LineCal
//
//  Created by tony on 2023/7/9.
//  Copyright © 2023 chengkaizone. All rights reserved.
//

import Foundation


/// 支付接口
public class HttpApi {

    /**
     * 添加数据
     */
    static let INSERT = "cloud/v2/db/mysql/insert"

    /**
     * 删除数据
     */
    static let DELETE = "cloud/v2/db/mysql/delete"

    /**
     * 更新数据
     */
    static let UPDATE = "cloud/v2/db/mysql/update"

    /**
     * 查询数据
     */
    static let SELECT = "cloud/v2/db/mysql/select"

    /**
     * sql命令执行
     */
    static let COMMAND = "cloud/v2/db/mysql/command"

    /**
     * 获取时间戳
     */
    static let TIMESTAMP = "cloud/api/timestamp"
    
    /**
     * 登录
     */
    static let LOGIN = "cloud/api/login"
    
    /**
     * 注册
     */
    static let REGISTER = "cloud/api/register"
    
    /**
     * 发送验证码 v2支持用户验证、客户端不需要再走查询接口
     */
    static let SEND_VERIFY_CODE = "cloud/v2/verify/send_code"
    
    /**
     * 验证验证码
     */
    static let VERIFY_CODE_VERIFY = "cloud/v2/verify/code_verify"
    
    /**
     * 云数据查询
     */
    static let  CLOUD_SELECT = "cloud/api/cloud/select"

    /**
     * 云数据添加
     */
    static let  CLOUD_ADD = "cloud/api/cloud/add"
    
}

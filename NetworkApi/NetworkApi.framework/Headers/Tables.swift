//
//  Tables.swift
//  LineCal
//
//  Created by tony on 2023/6/13.
//  Copyright © 2023 chengkaizone. All rights reserved.
//

import Foundation

/// 用户表
class TableUser {
    static let TABLE_NAME = "user" + NetworkSdk.getTableSuffix()
    static let ID = "id"
    static let USERNAME = "username"
    static let PASSWORD = "password"
    static let NICKNAME = "nickname"
    static let MOBILE = "mobile"
    static let EMAIL = "email"
    static let SEX = "sex"
    static let AVATAR = "avatar"
    static let BRAND = "brand"
    static let MODEL = "model"
    static let VIP_FOREVER = "vip_forever"
    static let AD_FREE = "ad_free"
    static let EXPIRE_TIME = "expire_time"
    static let APPLE_USER = "apple_user"
    static let CREATE_TIME = "create_time"
    static let UPDATE_TIME = "update_time"
    static let MODN_TIME = "modn_time"
}

/// 用户设置表
class TableUserSetting {
    static let TABLE_NAME = "user_setting" + NetworkSdk.getTableSuffix()
    static let ID = "id"
    static let UID = "uid"
    static let SETTINGS = "settings"
    static let DATA = "data"
    static let CREATE_TIME = "create_time"
    static let UPDATE_TIME = "update_time"
}

/// 订单表
class TableOrder {
    static let TABLE_NAME = "order" + NetworkSdk.getTableSuffix()
    static let ID = "id"
    static let UID = "uid"
    static let PAY_TYPE = "pay_type"
    static let PLATFORM_TYPE = "platform_type"
    static let TRADE_NO = "trade_no"
    static let GOODS_ID = "goods_id"
    static let CONTENT = "content"
    static let STATUS = "status"
    static let BRAND = "brand"
    static let MODEL = "model"
    static let VERSION = "version"
    static let CREATE_TIME = "create_time"
    static let UPDATE_TIME = "update_time"
}

/// 商品表
class TableGoods {
    static let TABLE_NAME = "goods" + NetworkSdk.getTableSuffix()
    static let ID = "id"
    static let CODE = "code"
    static let NAME = "name"
    static let DESCRIBE = "describe"
    static let CURRENCY = "currency"
    static let PRICE = "price"
    static let PRICE_ORIGINAL = "price_original"
    static let TYPE = "type" // 产品类型 0内购 1订阅 2订阅非连续
    static let LOCALE = "locale" // 地区
    static let DURATION = "duration" // 会员时长
    /**
     * 由bit位表示（00000011）, 1表示开启，0表示关闭，每一位代表一个平台
     * 低位第一位表示所有平台，1表示所有都开启，等于0时，继续判断平台标志位
     * 第2位表示Android，低位第3位代表iOS
     * 如果后续支持更多平台，依次开启后续位
     * 0表示所有都关闭，1：所有都开启、2：仅开启Android，4：仅开启iOS 6：开启Android和iOS
     */
    static let STATUS = "status"
    static let CREATE_TIME = "create_time"
    static let UPDATE_TIME = "update_time"
}

/// 兑换码表
class TableRedeemCode {
    static let TABLE_NAME = "redeem_code" + NetworkSdk.getTableSuffix()
    static let ID = "id"
    static let CODE = "code" // 兑换码
    static let TYPE = "type" // 0: 时长 1: 数量
    static let AMOUNT = "amount" // 兑换数量
    static let DESCRIBE = "describe"
    static let STATUS = "status" // 0不启用，1启用
    static let UID = "uid" // 关联使用的用户
    static let CREATE_TIME = "create_time"
    static let UPDATE_TIME = "update_time"
}

/// 云市场API接口数据表
class TableCloudData {
    static let TABLE_NAME = "cloud_data" + NetworkSdk.getTableSuffix()
    static let ID = "id"
    static let UID = "uid"
    static let CATE = "cate" // 数据分类
    static let TEXT = "text" // 接口内容
    static let MODEL = "model" // 上传设备型号
    static let IPADDR = "ipaddr" // ip地址
    static let CREATE_TIME = "create_time"
    static let UPDATE_TIME = "update_time"
}

/// 用户反馈数据表
class TableFeedback {
    static let TABLE_NAME = "feedback" + NetworkSdk.getTableSuffix()
    static let ID = "id"
    static let UID = "uid"
    static let TITLE = "title" // 反馈标题
    static let CONTENT = "content" // 反馈内容
    static let CONTACT = "contact" // 联系方式
    static let REPLY = "reply" // 回复内容
    static let BRAND = "brand" // 设备品牌
    static let MODEL = "model" // 设备型号
    static let IPADDR = "ipaddr" // ip地址
    static let CREATE_TIME = "create_time"
    static let UPDATE_TIME = "update_time"
}

/// 日志表
class TableLog {
    static let TABLE_NAME = "log" + NetworkSdk.getTableSuffix()
    static let ID = "id"
    static let TEXT = "text"
    static let CREATE_TIME = "create_time"
    static let UPDATE_TIME = "update_time"
}

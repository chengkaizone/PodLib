//
//  PayType.swift
//  LineCal
//
//  Created by tony on 2023/7/23.
//  Copyright © 2023 chengkaizone. All rights reserved.
//

import Foundation

public enum PayType : Int {
    case WXPAY = 10
    case ALIPAY = 11
    case PAYPAL = 12
    case APPLE = 13
    
    public func getCode() -> String {
        switch self {
        case .WXPAY:
            return "wxpay"
        case .ALIPAY:
            return "alipay"
        case .PAYPAL:
            return "paypal"
        case .APPLE:
            return "apple"
        }
    }
    
}

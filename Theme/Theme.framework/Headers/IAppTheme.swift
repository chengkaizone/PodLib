//
//  IAppTheme.swift
//  theme
//
//  Created by tony on 2024/2/14.
//

import UIKit


/// 主题接口
public protocol IAppTheme {
    
    
    func getVip() -> Bool

    func getName() -> String

    func getTimeId() -> String?

    func getPrimary() -> String

    func getAccent() -> String

    func getExtra() -> String

    func getPrimaryColor() -> UIColor

    func getAccentColor() -> UIColor

    func getExtraColor() -> UIColor

    func getIdentifier() -> String

    func toJSONString() -> String

    func clone() -> IAppTheme
    
}

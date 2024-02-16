//
//  IThemeLoader.swift
//  theme
//
//  Created by tony on 2024/2/14.
//

import Foundation

public protocol IThemeLoader {
    
    /**
     * 主题色
     * @return
     */
    func primaryColor() -> Int

    /**
     * 次要颜色
     * @return
     */
    func accentColor() -> Int

    /**
     * 辅助色
     * @return
     */
    func extraColor() -> Int
    
}

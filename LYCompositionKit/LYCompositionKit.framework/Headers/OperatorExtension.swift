//
//  OperatorExtension.swift
//  LYCompositionKit
//
//  Created by tony on 16/9/17.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import Foundation

import Foundation

func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

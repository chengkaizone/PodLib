//
//  LYImageTarget.swift
//  CameraFilter
//
//  Created by tony on 2017/6/7.
//  Copyright © 2017年 chengkaizone. All rights reserved.
//

import Foundation
import CoreImage

public protocol LYImageTarget: NSObjectProtocol {
    
    // 设置原始图片
    func setImage(ciImage: CIImage)
    
}

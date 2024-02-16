//
//  CGSizeExtension.swift
//  LYCompositionKit
//
//  Created by tony on 2017/1/15.
//  Copyright © 2017年 chengkai. All rights reserved.
//

import Foundation

extension CGSize {
    
    func isVertical() ->Bool {
        
        return self.height > self.width
    }
    
    func scaledSize(scale: CGFloat) -> CGSize {
        return CGSize(width: width * scale, height: height * scale)
    }
    
}


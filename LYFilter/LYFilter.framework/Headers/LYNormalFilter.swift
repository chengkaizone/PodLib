//
//  LYNormalFilter.swift
//  LineVideo
//
//  Created by tony on 2018/1/14.
//  Copyright © 2018年 chengkaizone. All rights reserved.
//

/// 原始
public class LYNormalFilter: LYImageFilter {
    
    public override init() {
        
        super.init(fragmentShader: LYNormalFragmentShader)
    }
    
}

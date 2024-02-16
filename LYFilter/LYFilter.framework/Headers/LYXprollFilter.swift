//
//  LYXprollFilter.swift
//  LineVideo
//
//  Created by tony on 2018/1/14.
//  Copyright © 2018年 chengkaizone. All rights reserved.
//

/// 暮色 quiet
public class LYXprollFilter: LYImageFilter {
    
    public override init() {
        
        super.init(fragmentShader: LYXprollFragmentShader, inputs: [LYImageFilter.pictureInput(name: "quietMap"), LYImageFilter.pictureInput(name: "vignetteMap")])
    }
    
}

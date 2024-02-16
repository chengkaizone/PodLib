//
//  LYInkwellFilter.swift
//  LineVideo
//
//  Created by tony on 2018/1/14.
//  Copyright © 2018年 chengkaizone. All rights reserved.
//

/// 黑白 chrome
public class LYInkwellFilter: LYImageFilter {
    
    public override init() {
        
        super.init(fragmentShader: LYInkwellFragmentShader, inputs: [LYImageFilter.pictureInput(name: "chromeMap")])
    }
    
}

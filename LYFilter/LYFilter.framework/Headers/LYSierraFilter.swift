//
//  LYSierraFilter.swift
//  LineVideo
//
//  Created by tony on 2018/1/14.
//  Copyright © 2018年 chengkaizone. All rights reserved.
//

/// 清新 fresh
public class LYSierraFilter: LYImageFilter {
    
    public override init() {
        
        super.init(fragmentShader: LYSierraFragmentShader, inputs: [LYImageFilter.pictureInput(name: "freshVignette"), LYImageFilter.pictureInput(name: "overlayMap"), LYImageFilter.pictureInput(name: "freshMap")])
    }
    
}

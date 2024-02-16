//
//  LYHefeFilter.swift
//  LineVideo
//
//  Created by tony on 2018/1/14.
//  Copyright © 2018年 chengkaizone. All rights reserved.
//

/// 记忆/回忆 memory
public class LYHefeFilter: LYImageFilter {
    
    public override init() {
        
        super.init(fragmentShader: LYHefeFragmentShader, inputs: [LYImageFilter.pictureInput(name: "edgeBurn"), LYImageFilter.pictureInput(name: "memoriesMap"), LYImageFilter.pictureInput(name: "memoriesGradientMap"), LYImageFilter.pictureInput(name: "memoriesSoftLight"), LYImageFilter.pictureInput(name: "memoriesMetal")])
    }
    
}


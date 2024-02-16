//
//  LYWaldenFilter.swift
//  LineVideo
//
//  Created by tony on 2018/1/14.
//  Copyright © 2018年 chengkaizone. All rights reserved.
//

/// 暮光 twilight
public class LYWaldenFilter: LYImageFilter {

    public override init() {
        
        super.init(fragmentShader: LYWaldenFragmentShader, inputs: [LYImageFilter.pictureInput(name: "twilightMap"), LYImageFilter.pictureInput(name: "vignetteMap")])
    }
    
}

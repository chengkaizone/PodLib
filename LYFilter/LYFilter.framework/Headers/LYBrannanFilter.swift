//
//  LYBrannanFilter.swift
//  LineVideo
//
//  Created by tony on 2018/1/14.
//  Copyright © 2018年 chengkaizone. All rights reserved.
//

/// 复古 retro
public class LYBrannanFilter: LYImageFilter {

    public override init() {
        
        super.init(fragmentShader: LYBrannanFragmentShader, inputs: [LYImageFilter.pictureInput(name: "retroProcess"), LYImageFilter.pictureInput(name: "retroBlowout"), LYImageFilter.pictureInput(name: "retroContrast"), LYImageFilter.pictureInput(name: "retroLuma"), LYImageFilter.pictureInput(name: "retroScreen")])
    }
    
}

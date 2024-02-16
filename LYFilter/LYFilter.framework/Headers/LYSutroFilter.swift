//
//  LYSutroFilter.swift
//  LineVideo
//
//  Created by tony on 2018/1/14.
//  Copyright © 2018年 chengkaizone. All rights reserved.
//

/// 夜间 night
public class LYSutroFilter: LYImageFilter {

    public override init() {
        
        super.init(fragmentShader: LYSutroFragmentShader, inputs: [LYImageFilter.pictureInput(name: "vignetteMap"), LYImageFilter.pictureInput(name: "nightMetal"), LYImageFilter.pictureInput(name: "softLight"), LYImageFilter.pictureInput(name: "nightEdgeBurn"), LYImageFilter.pictureInput(name: "nightCurves")])
    }
    
}

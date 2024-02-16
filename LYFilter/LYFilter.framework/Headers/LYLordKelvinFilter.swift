//
//  LYLordKelvinFilter.swift
//  LineVideo
//
//  Created by tony on 2018/1/14.
//  Copyright © 2018年 chengkaizone. All rights reserved.
//

/// 古城 ancientcity
public class LYLordKelvinFilter: LYImageFilter {

    public override init() {
        
        super.init(fragmentShader: LYLordKelvinFragmentShader, inputs: [LYImageFilter.pictureInput(name: "ancientcityMap")])
    }
    
}


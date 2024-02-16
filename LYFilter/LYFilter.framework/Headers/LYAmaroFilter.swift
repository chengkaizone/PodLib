//
//  LYAmatoFilter.swift
//  LineVideo
//
//  Created by tony on 2018/1/14.
//  Copyright © 2018年 chengkaizone. All rights reserved.
//

/// 灯光 light
public class LYAmaroFilter: LYImageFilter {

    public override init() {
        
        super.init(fragmentShader: LYAmaroFragmentShader, inputs: [LYImageFilter.pictureInput(name: "blackboardLarge"), LYImageFilter.pictureInput(name: "overlayMap"), LYImageFilter.pictureInput(name: "lightMap")])
    }
    
}

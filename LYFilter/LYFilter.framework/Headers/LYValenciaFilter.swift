//
//  LYValenciaFilter.swift
//  LineVideo
//
//  Created by tony on 2018/1/14.
//  Copyright © 2018年 chengkaizone. All rights reserved.
//

/// 自然 natural
public class LYValenciaFilter: LYImageFilter {
    
    public override init() {
        
        super.init(fragmentShader: LYValenciaFragmentShader, inputs: [LYImageFilter.pictureInput(name: "naturalMap"), LYImageFilter.pictureInput(name: "naturalGradientMap")])
    }
    
}

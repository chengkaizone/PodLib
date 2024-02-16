//
//  LYCompositionBuilder.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import AVFoundation

/** 资源生成器 */
public protocol LYCompositionBuilder: NSObjectProtocol {
    
    /**
     * 创建合成
     * 预览和导出同时创建
     */
    func buildComposition() ->LYComposition
    
    /**
     * 创建预览
     */
    func buildCompositionPlayback() ->LYComposition
    
    /**
     * 创建导出
     */
    func buildCompositionExport() ->LYComposition
    
}

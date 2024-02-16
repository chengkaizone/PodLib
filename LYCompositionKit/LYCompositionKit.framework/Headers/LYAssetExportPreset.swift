//
//  LYAssetExportPreset.swift
//  LYCompositionKit
//
//  Created by tony on 16/6/25.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import Foundation

/**
 * 针对图片导出的预设 --- 需要据此计算出最大支持的图片数量
 */
public enum LYAssetExportPreset: String {
    
    // 4:3
    case Preset320x240 = "320x240"
    // 16:9
    case Preset480x270 = "480x270"
    // 16:9
    case Preset640x360 = "640x360"
    // 4:3
    case Preset640x480 = "640x480"
    // 16:9
    case Preset960x540 = "960x540"
    // 16:9
    case Preset1280x720 = "1280x720"
    // 16:9
    case Preset1920x1080 = "1920x1080"
    
    /**
     * 获取支持的预设
     */
    public static func supportPresets() ->[LYAssetExportPreset] {

        return [.Preset320x240,
                .Preset480x270,
                .Preset640x360,
                .Preset640x480,
                .Preset960x540,
                .Preset1280x720,
                .Preset1920x1080]
    }
    
    /**
     * 获取支持的预设
     */
    public static func supportPresetsString() ->[String] {
        
        return [LYAssetExportPreset.Preset320x240.rawValue,
                LYAssetExportPreset.Preset480x270.rawValue,
                LYAssetExportPreset.Preset640x360.rawValue,
                LYAssetExportPreset.Preset640x480.rawValue,
                LYAssetExportPreset.Preset960x540.rawValue,
                LYAssetExportPreset.Preset1280x720.rawValue,
                LYAssetExportPreset.Preset1920x1080.rawValue]
    }
    
    /**
     * 取出较大值
     */
    public static func maxValue(_ preset: String) ->Int {
        
        // 拆解预设
        let dimens = preset.components(separatedBy: "x")
        let width = NSString(string: dimens[0]).integerValue
        let height = NSString(string: dimens[1]).integerValue
        
        let result = max(width, height)
        
        return result
    }
    
    /**
     * 取出小值
     */
    public static func minValue(_ preset: String) ->Int {
        
        // 拆解预设
        let dimens = preset.components(separatedBy: "x")
        let width = NSString(string: dimens[0]).integerValue
        let height = NSString(string: dimens[1]).integerValue
        
        let result = min(width, height)
        
        return result
    }
    
    /**
     * 计算每个片段使用预设需要的内存大小
     * 返回的字节数
     */
    public static func calculateStorageSize(_ preset: LYAssetExportPreset) ->Int64 {
        
        return calculateStorageSize(preset.rawValue)
    }
    
    /**
     * 计算每个片段使用预设需要的内存大小
     * preset满足'320x240'格式即可, 适用于自由尺寸
     * 返回的字节数
     */
    public static func calculateStorageSize(_ preset: String) ->Int64 {
        
        // 拆解预设
        let dimens = preset.components(separatedBy: "x")
        let width = NSString(string: dimens[0]).longLongValue
        let height = NSString(string: dimens[1]).longLongValue
        
        return width * height * 4
    }
    
}

//
//  LYAssetRepresentation.swift
//  LYCompositionKit
//
//  Created by tony on 16/6/19.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit
import AssetsLibrary
import CoreLocation

/// 用于保存访问ALAsset得到的属性
open class LYAssetRepresentation: NSObject {
    
    open var UTI: String!
    open var dimensions: CGSize!
    open var size: Int64!
    
    open var metadata: [AnyHashable: Any]!
    //open var orientation: ALAssetOrientation!
    open var scale: Float!
    
    open var url: URL!
    open var editable: Bool!
    open var type: String!
    open var location: CLLocation!
    open var duration: NSNumber!
    open var date: Date!
    
    // 使用本地视频文件初始化
    init(localURL: URL) {
        
        url = localURL
        super.init()
    }

    
    /*
    init(asset: ALAsset, representation: ALAssetRepresentation) {
        self.UTI = representation.uti();
        self.dimensions = representation.dimensions();
        self.size = representation.size();
        self.metadata = representation.metadata();
        self.orientation = representation.orientation();
        self.scale = representation.scale();
        self.url = representation.url();
        
        self.editable = asset.isEditable
        self.type = asset.value(forProperty: ALAssetPropertyType) as? String
        self.location = asset.value(forProperty: ALAssetPropertyLocation) as? CLLocation
        self.duration = asset.value(forProperty: ALAssetPropertyDuration) as? NSNumber
        self.date = asset.value(forProperty: ALAssetPropertyDate) as? Date
        
        super.init()
    }
 */
    
}

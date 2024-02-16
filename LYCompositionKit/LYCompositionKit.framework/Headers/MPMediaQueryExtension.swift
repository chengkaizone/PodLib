//
//  MPMediaQueryExtension.swift
//  LYCompositionKit
//
//  Created by tony on 2016/11/26.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import Foundation
import MediaPlayer

public extension MPMediaQuery {
    
    /**
     * 是否存在音乐库中
     */
    public class func existAlbums(url: URL) -> Bool {
        let query = MPMediaQuery.albums()
        if let items = query.items {
            for item in items {
                let tmpUrl = item.value(forProperty: MPMediaItemPropertyAssetURL) as! URL
                
                if url == tmpUrl {
                    return true
                }
            }
        }
        
        return false
    }
    
}

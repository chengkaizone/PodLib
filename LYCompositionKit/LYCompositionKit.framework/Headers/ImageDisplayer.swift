//
//  ImageDisplayer.swift
//  LYCompositionKit
//
//  Created by tony on 2016/11/12.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

/// 图片预览显示器
@objc public protocol ImageDisplayer {
    
    // 显示图片
    func displayImage(_ imageView: UIImageView, _ asset: AVAsset, _ localIdentifier: String!, _ mediaType: PHAssetMediaType, _ time: CMTime, _ itemSize: CGSize, _ imageGenerator:AVAssetImageGenerator)

}

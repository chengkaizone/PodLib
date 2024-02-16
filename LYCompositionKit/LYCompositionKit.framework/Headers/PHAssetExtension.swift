//
//  PHAssetExtension.swift
//  LYCompositionKit
//
//  Created by tony on 2016/12/26.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit
import Photos

extension PHAsset {
    
    func isVertical() ->Bool {
        
        return self.pixelHeight > self.pixelWidth
    }
    
    /// 获取原始大图
    func sourceImage() ->UIImage! {
        let options = PHImageRequestOptions()
        options.version = PHImageRequestOptionsVersion.current
        // iCloud中的备份
        // options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        
        var sourceImage: UIImage!
        PHImageManager.default().requestImage(for: self, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: options) { (image: UIImage?, info: [AnyHashable : Any]?) in
            
            sourceImage = image
        }

        return sourceImage
    }
    
    /// 获取原始大图
    func sourceImageAndSize() ->(UIImage?, CGSize) {
        let options = PHImageRequestOptions()
        options.version = PHImageRequestOptionsVersion.current
        // iCloud中的备份
        // options.isNetworkAccessAllowed = true
        
        options.isSynchronous = true
        
        var sourceImage: UIImage!
        PHImageManager.default().requestImage(for: self, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: options) { (image: UIImage?, info: [AnyHashable : Any]?) in
            
            sourceImage = image
        }
        var size = CGSize.zero
        if sourceImage != nil {
            size = sourceImage.size
        }
        return (sourceImage, size)
    }
    
    /**
     * 获取目标尺寸图片 aspectFill
     * 提取的图片不会超出原始尺寸
     */
    func image(targetSize: CGSize) ->UIImage? {
        let options = PHImageRequestOptions()
        options.version = PHImageRequestOptionsVersion.current
        options.resizeMode = .exact
        options.deliveryMode = .highQualityFormat
        // iCloud中的备份
        // options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        
        var targetImage: UIImage!
        PHImageManager.default().requestImage(for: self, targetSize: targetSize, contentMode: .default, options: options) { (image: UIImage?, info: [AnyHashable : Any]?) in
            
            targetImage = image
        }
        
        return targetImage
    }
    
    /// 获取视频资源
    func avAsset() -> AVURLAsset? {
        
        var resultAVAsset: AVAsset?
        let semaphore = DispatchSemaphore(value: 0)
        
        PHImageManager.default().requestAVAsset(forVideo: self, options: nil, resultHandler: { (avAsset: AVAsset?, avAudio: AVAudioMix?, dict: [AnyHashable : Any]?) in
            
            resultAVAsset = avAsset
            semaphore.signal()
        })
        
        let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return resultAVAsset as? AVURLAsset
    }
    
    /**
     * 通过唯一标识符获取相册资源
     */
    class func fetchAsset(localIdentifier: String!) ->PHAsset? {
        if localIdentifier == nil {
            return nil
        }
        
        let fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        
        if fetchResult.count >= 1 {
            return fetchResult[0]
        }
        
        return nil
    }
    
    /**
     * 检索是否存在标识符
     */
    class func exist(localIdentifier: String!) ->Bool {
        if localIdentifier == nil {
            return false
        }
        
        let fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        
        if fetchResult.count >= 1 {
            return true
        }
        
        return false
    }
    
}

//
//  LYMovieWriter.swift
//  CameraFilter
//
//  Created by tony on 2017/6/7.
//  Copyright © 2017年 chengkaizone. All rights reserved.
//

import UIKit
import AVFoundation

public protocol LYMovieWriterDelegate: NSObjectProtocol {
    
    func didWriteMovie(outputURL url: URL)
    
    // 取消录制视频
    func didWriteMovieCanceled()
    
    // 未知状态
    func didWriteMovieUnknow()
    
}

public enum WriteStatus: Int {
    
    case idle = 0 // 空闲中
    case writing = 1 // 写入中
    case finish = 2 // 结束写入
}

// 样本处理
public class LYMovieWriter: NSObject {
    
    open weak var delegate: LYMovieWriterDelegate?
    
    let VIDEO_FILENAME = "movie.mov"
    
    // 是否处于写入状态
    open var writeStatus: WriteStatus = .idle
    
    var ciContext: CIContext!
    var colorSpace: CGColorSpace!
    var activeFilter: CIFilter!
    
    var assetWriter: AVAssetWriter!
    var assetWriterVideoInput: AVAssetWriterInput!
    var assetWriterAudioInput: AVAssetWriterInput!
    var assetWriterInputPixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor!
    
    var videoSettings: [String: Any]!
    var audioSettings: [String: Any]!
    
    var position: AVCaptureDevice.Position!
    
    var dispatchQueue: DispatchQueue!
    
    override init() {
        super.init()
        
        writeStatus = .idle
    }
    
    init(position: AVCaptureDevice.Position, videoSettings: [String: Any], audioSettings: [String: Any]?, dispatchQueue: DispatchQueue) {
        super.init()
        
        self.position = position
        self.videoSettings = videoSettings
        self.audioSettings = audioSettings
        self.dispatchQueue = dispatchQueue
        
        self.ciContext = LYContextManager.shared().ciContext
        self.colorSpace = CGColorSpaceCreateDeviceRGB()
        
        NotificationCenter.default.addObserver(self, selector: #selector(filterChanged(_:)), name: NSNotification.Name(rawValue: LYPhotoFilter.FilterSelectedChangedNotification), object: nil)
    }
    
    deinit {
    
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func filterChanged(_ notification: Notification) {
        
        self.activeFilter = (notification.object as? CIFilter)?.copy() as? CIFilter
    }
    
    func transform(orientation: UIDeviceOrientation) ->CGAffineTransform {
        
        var result: CGAffineTransform!
        
        switch orientation {
        case .landscapeRight:
            result = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            break
        case .portraitUpsideDown:
            result = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2 * 3))
            break
        case .portrait, .faceUp, .faceDown:
            result = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
            break
        default:
            result = CGAffineTransform.identity
            break
        }
        
        return result
    }
    
    open func startWriting() {
        
        if writeStatus == .finish {// 如果还没有写入完成, 不开始
            return
        }
        
        let fileType = AVFileType.mov
        let url = self.generateOutputURL()
        do {
            self.assetWriter = try AVAssetWriter(url: url, fileType: fileType) // 2
            
            // 3
            self.assetWriterVideoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: self.videoSettings)
            
            self.assetWriterVideoInput.expectsMediaDataInRealTime = true
            
            // 4
            let orientation = UIDevice.current.orientation
            self.assetWriterVideoInput.transform = self.transform(orientation: orientation)
            
            // 5
            var attributes = [String: Any]()
            attributes[String(kCVPixelBufferPixelFormatTypeKey)] = NSNumber(value: kCVPixelFormatType_32BGRA)
            attributes[String(kCVPixelBufferWidthKey)] = self.videoSettings[AVVideoWidthKey]
            attributes[String(kCVPixelBufferHeightKey)] = self.videoSettings[AVVideoHeightKey]
            attributes[String(kCVPixelFormatOpenGLESCompatibility)] = NSNumber(value: kCFBooleanTrue as! Bool)
            
            // DLog("width: \(String(describing: self.videoSettings[AVVideoWidthKey]))   \(String(describing: self.videoSettings[AVVideoHeightKey]))")
            // 6
            self.assetWriterInputPixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: self.assetWriterVideoInput, sourcePixelBufferAttributes: attributes)
            
            // 7
            if self.assetWriter.canAdd(self.assetWriterVideoInput) {
                self.assetWriter.add(self.assetWriterVideoInput)
            } else {
                NSLog("Unable to add video input.")
                return
            }
            
            if audioSettings != nil {
                // 8
                self.assetWriterAudioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: self.audioSettings)
                self.assetWriterAudioInput.expectsMediaDataInRealTime = true
                
                // 9
                if self.assetWriter.canAdd(self.assetWriterAudioInput) {
                    self.assetWriter.add(self.assetWriterAudioInput)
                } else {
                    NSLog("Unable to add audio input.")
                }
            }
            
            // 10
            writeStatus = .writing
        } catch let error {
            NSLog("Could not create AVAssetWriter: \(error.localizedDescription)")
            writeStatus = .idle
            return
        }
        
    }
    
    /// 停止录制
    open func stopWriting(_ isCancelled: Bool = false) {/// 同步能保证原子性
        
        writeStatus = .finish
        
        if self.assetWriter == nil {// 原子性操作
            self.writeStatus = .idle
            self.delegate?.didWriteMovieUnknow()
            return
        }
        
        if self.assetWriter.status != .writing {
            self.writeStatus = .idle
            self.delegate?.didWriteMovieUnknow()
            return
        }
        
        let url = self.assetWriter.outputURL
        
        if isCancelled {
            do {
                try FileManager.default.removeItem(at: url)
            } catch let error {
                NSLog("删除本地视频错误 error: \(error.localizedDescription)")
            }
            self.assetWriter.endSession(atSourceTime: CMTime.zero)
            
            self.writeStatus = .idle
            self.delegate?.didWriteMovieCanceled()
            return
        }
        
        /// 此处是异步操作
        self.assetWriter?.finishWriting(completionHandler: {[weak self] in
            
            if self == nil {
                return
            }
            
            NSLog("完成写入!!!")
            if self?.assetWriter?.status == .completed {
                
                self?.writeStatus = .idle
                DispatchQueue.main.async {
                    self?.delegate?.didWriteMovie(outputURL: url)
                }
            }
        })
        
    }
    
    
    open func process(sampleBuffer: CMSampleBuffer) {
        
        if self.writeStatus != .writing {// 非写入状态不处理
            return
        }
        
        if self.assetWriter == nil {// 还没有初始化完成
            return
        }
        
        if let formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer) {
            let mediaType = CMFormatDescriptionGetMediaType(formatDesc)
            
            if mediaType == kCMMediaType_Video {
                
                let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                
                if self.assetWriter.status != .writing {
                    if self.assetWriter.startWriting() {
                        self.assetWriter.startSession(atSourceTime: timestamp)
                    } else {
                        NSLog("Failed to start writing")
                        return
                    }
                }
                
                var outputRendererBuffer: CVPixelBuffer?
                
                guard let pixelBufferPool = self.assetWriterInputPixelBufferAdaptor.pixelBufferPool else {
                    return
                }
                
                let status = CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool, &outputRendererBuffer)
                
                if status != 0 {
                    NSLog("Unable to obtain a pixel buffer from the pool.")
                    return
                }
                
                guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                    
                    return
                }
                
                let sourceImage = CIImage(cvPixelBuffer: imageBuffer, options: nil)
                // 滤镜为空的情况
                self.activeFilter?.setValue(sourceImage, forKey: kCIInputImageKey)
                
                var filteredImage = self.activeFilter?.outputImage
                
                if filteredImage == nil {
                    filteredImage = sourceImage
                }
                
                if self.position == .front {// 如果是前置摄像头需要做镜像调整
                    NSLog("前置摄像头需要做镜像调整")
                }
                
                self.ciContext.render(filteredImage!, to: outputRendererBuffer!, bounds: filteredImage!.extent, colorSpace: self.colorSpace)
                
                if self.assetWriterVideoInput.isReadyForMoreMediaData {
                    
                    if writeStatus == .writing {
                        // 写入视频文件的时候是截取上面, 丢弃下面部分
                        if self.assetWriterInputPixelBufferAdaptor.append(outputRendererBuffer!, withPresentationTime: timestamp) == false {
                            NSLog("Error appending pixel buffer.")
                        }
                    } else {
                        NSLog("write status: \(writeStatus.rawValue)")
                    }
                    
                }
                
            } else if self.assetWriter.status == .writing && mediaType == kCMMediaType_Audio {
                if self.assetWriterAudioInput.isReadyForMoreMediaData {
                    
                    if self.assetWriterAudioInput.append(sampleBuffer) == false {
                         NSLog("Error appending audio sample buffer.")
                    }
                }
            }
        }
        
    }
    
    fileprivate func generateOutputURL() ->URL {
        
        let filePath = NSTemporaryDirectory().appending(VIDEO_FILENAME)
        let url = URL(fileURLWithPath: filePath)
        
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch let error {
                //
                NSLog("generateOutputURL error: \(error.localizedDescription)")
            }
        }
        
        return url
    }
    
}

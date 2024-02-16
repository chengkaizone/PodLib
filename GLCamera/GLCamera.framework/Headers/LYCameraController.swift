//
//  LYCameraController.swift
//  CameraFilter
//
//  Created by tony on 2017/6/7.
//  Copyright © 2017年 chengkaizone. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

protocol LYCameraControllerDelegate: NSObjectProtocol {
    
    /// 相机录制状态改变
    func cameraController(controller: LYCameraController, statusChanged isRecording: Bool)
    
    /// 不自动保存到相册时, 返回视频的URL地址
    func cameraController(controller: LYCameraController, localURL: URL)
    
    /// 自动保存到相册的情况下, 返回保存到相册的标识符, nil表示保存失败
    func cameraController(controller: LYCameraController, localIdentifier: String!)
    
}

public class LYCameraController: LYBaseCameraController {
    
    weak var delegate: LYCameraControllerDelegate?
    
    weak var imageTarget: LYImageTarget?
    
    // 自动保存到相册
    open var automaticSaveToAlbum: Bool = true
    
    open var isRecording: Bool = false {
        didSet {
            
            DispatchQueue.main.async {[weak self] in
                
                if self == nil {
                    return
                }
                
                self?.delegate?.cameraController(controller: self!, statusChanged: self!.isRecording)
            }
            
        }
    }
    
    var videoDataOutput: AVCaptureVideoDataOutput!
    var audioDataOutput: AVCaptureAudioDataOutput!
    
    var movieWriter: LYMovieWriter!
    // 预览尺寸比例
    var previewRatio: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1) {
        
        didSet {// 此处需要调整视频预览输出的设置
            let _ = self.setupSessionOutputs()
        }
    }
    
     public override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func didEnterBackground(_ notification: Notification) {
        
        if isRecording {
            self.stopRecording(true)
        }
    }
    
    @objc func didBecomeActive(_ notification: Notification) {
        
    }
    
    public override func setupSessionOutputs() -> Bool {
        
        if movieWriter != nil {
            
            if self.movieWriter.writeStatus == .finish {// 正在完成写入不处理
                return false
            } else if self.movieWriter.writeStatus == .writing {// 先停止录制
                self.movieWriter.stopWriting(true)
                self.isRecording = false
            }
        }
        
        if captureSession == nil {// 尚未初始化
            return false
        }
        
        if videoDataOutput != nil {
            self.captureSession.removeOutput(videoDataOutput)
            self.videoDataOutput = nil
        }
        
        if audioDataOutput != nil {
            self.captureSession.removeOutput(audioDataOutput)
            self.audioDataOutput = nil
        }
        
        self.videoDataOutput = AVCaptureVideoDataOutput() // 1
        let outputSettings = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)]
        self.videoDataOutput.videoSettings = outputSettings
        
        self.videoDataOutput.alwaysDiscardsLateVideoFrames = false // 2
        self.videoDataOutput.setSampleBufferDelegate(self, queue: self.dispatchQueue)
        
        let videoAuthorized = AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized
        if videoAuthorized {
            if self.captureSession.canAddOutput(videoDataOutput) {
                self.captureSession.addOutput(videoDataOutput)
            } else {
                return false
            }
        }
    
        self.audioDataOutput = AVCaptureAudioDataOutput() // 3
        self.audioDataOutput.setSampleBufferDelegate(self, queue: self.dispatchQueue)
        
        let audioAuthorized = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) == .authorized
        if audioAuthorized {
            if self.captureSession.canAddOutput(audioDataOutput) {
                self.captureSession.addOutput(audioDataOutput)
            } else {
                return false
            }
        }
        
        let fileType = AVFileType.mov
        
        var videoSettings = self.videoDataOutput.recommendedVideoSettingsForAssetWriter(writingTo: fileType)

    NSLog("videoSettings: \(String(describing: videoSettings))")
        
        // 因为旋转了90度, 所以, 宽即是高
        let defaultWidth = (videoSettings![AVVideoWidthKey] as! NSNumber).doubleValue
        let defaultHeight = (videoSettings![AVVideoHeightKey] as! NSNumber).doubleValue
        
        let destWidth = defaultWidth * Double(previewRatio.size.height)
        let destHeight = defaultHeight * Double(previewRatio.size.width)
//
        //DLog("dest size: \(previewRatio)   \(defaultWidth)   \(defaultHeight)")
        videoSettings![AVVideoWidthKey] = NSNumber(value: destWidth)
        videoSettings![AVVideoHeightKey] = NSNumber(value: destHeight)
        
        let audioSettings = self.audioDataOutput.recommendedAudioSettingsForAssetWriter(writingTo: fileType)
        
        self.movieWriter = LYMovieWriter(position: self.activeCamera().position, videoSettings: videoSettings!, audioSettings: audioSettings as? [String : Any], dispatchQueue: self.dispatchQueue)
        
        self.movieWriter.delegate = self
        
        return true
    }
    
    // 改变闪光灯的状态
    public func flashStatusChange() -> AVCaptureDevice.TorchMode {
        
        let camera = activeCamera()
        if camera.hasFlash == false || camera.hasTorch == false {
            
            return .auto
        }
        
        var mode = camera.torchMode
        
        switch mode {
        case .on:
            mode = .off
            break
        case .off:
            mode = .auto
            break
        case .auto:
            mode = .on
            break
        }
        
        do {
            try camera.lockForConfiguration()
            
            camera.torchMode = mode
            camera.unlockForConfiguration()
        } catch {
            
        }
        
        return mode
    }
    
    // 获取手指点击的焦点
    public func focus(point: CGPoint) {
        
        let camera = activeCamera()
        
        if camera.isFocusModeSupported(.autoFocus) == false || camera.isFocusPointOfInterestSupported == false {
            
            return
        }
        
        do {
            
            try camera.lockForConfiguration()
            camera.focusMode = .autoFocus
            camera.focusPointOfInterest = point
            camera.unlockForConfiguration()
        } catch let error {
            NSLog("error: \(error.localizedDescription)")
        }
        
    }
    
    open func startRecording() {
        
        self.movieWriter?.startWriting()
        self.isRecording = true
    }
    
    open func stopRecording(_ isCancelled: Bool = false) {
        
        self.movieWriter?.stopWriting(isCancelled)
        
        if self.delegate == nil {
            self.isRecording = false
        } else {// 代理中回调
            
        }
        
    }
    
}

// 音视频输出的二次处理
extension LYCameraController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        // 处理帧---输入视频文件
        self.movieWriter.process(sampleBuffer: sampleBuffer)
        
        if captureOutput == self.videoDataOutput {
            
            if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                let sourceImage = CIImage(cvPixelBuffer: imageBuffer, options: nil)
                
                // 设置图片通过GLKView(OpenGL)渲染到屏幕上
                self.imageTarget?.setImage(ciImage: sourceImage)
            }
        }
    }
}

extension LYCameraController: LYMovieWriterDelegate {
    
    public func didWriteMovie(outputURL url: URL) {
        
        if self.automaticSaveToAlbum {
            
            var localIdentifier: String!
            // 保存到相册
            PHPhotoLibrary.shared().performChanges({
                
                if #available(iOS 9.0, *) {
                    localIdentifier = PHAssetCreationRequest.creationRequestForAssetFromVideo(atFileURL: url)?.placeholderForCreatedAsset?.localIdentifier
                } else {
                    // Fallback on earlier versions
                }
            }) {[weak self] (result: Bool, error: Error?) in
                
                self?.isRecording = false
                if error != nil {
                    NSLog("保存到相册错误 error: \(error!.localizedDescription)")
                    self?.delegate?.cameraController(controller: self!, localIdentifier: nil)
                } else {
                    do {
                        try FileManager.default.removeItem(at: url)
                    } catch let error {
                        NSLog("删除本地视频错误 error: \(error.localizedDescription)")
                    }
                    
                    DispatchQueue.main.async {
                        self?.delegate?.cameraController(controller: self!, localIdentifier: localIdentifier)
                    }
                }
            }
        } else {
            self.isRecording = false
            self.delegate?.cameraController(controller: self, localURL: url)
        }
        
    }
    
    public func didWriteMovieCanceled() {
        self.isRecording = false
        self.delegate?.cameraController(controller: self, statusChanged: self.isRecording)
    }
    
    public func didWriteMovieUnknow() {
        self.isRecording = false
        self.delegate?.cameraController(controller: self, statusChanged: self.isRecording)
    }
    
}


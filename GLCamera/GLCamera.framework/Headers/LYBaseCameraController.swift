//
//  LYBaseCameraController.swift
//  CameraFilter
//
//  Created by tony on 2017/6/7.
//  Copyright © 2017年 chengkaizone. All rights reserved.
//

import UIKit
import AVFoundation

public class LYBaseCameraController: NSObject {
    
    open var captureSession: AVCaptureSession!
    open var dispatchQueue: DispatchQueue!
    
    var activeVideoInput: AVCaptureDeviceInput!
    var outputURL: URL!
    
    var sessionPreset: AVCaptureSession.Preset {
        get {
            return AVCaptureSession.Preset.high
        }
    }
    
    public override init() {
        super.init()
        
        self.dispatchQueue = DispatchQueue(label: "com.tony.LYBaseCameraController")
    }
    
    open func setupSession() ->Bool {
        
        self.captureSession = AVCaptureSession()
        self.captureSession.sessionPreset = self.sessionPreset
        
        if self.setupSessionInputs() == false {
            return false
        }
        
        if self.setupSessionOutputs() == false {
            return false
        }
        
        return true
    }
    
    open func setupSessionInputs() ->Bool {
        
        let videoDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        // 添加相机设备
        do {
            
            let videoInput = try AVCaptureDeviceInput.init(device: videoDevice!)
            
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
                self.activeVideoInput = videoInput
            } else {
                // TODO 处理错误
                return false
            }
        } catch let error {
            NSLog("setupSessionInputs add videoInput error: \(error.localizedDescription)")
            return false
        }
        
        
        let audioAuthorized = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) == .authorized
        if audioAuthorized {
            // 添加音频设备
            let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
            
            do {
                
                let audioInput = try AVCaptureDeviceInput.init(device: audioDevice!)
                if captureSession.canAddInput(audioInput) {
                    captureSession.addInput(audioInput)
                } else {
                    // TODO
                    return false
                }
            } catch let error {
                NSLog("setupSessionInputs add audioInput error: \(error.localizedDescription)")
                return false
            }
        }
        
        return true
    }
    
    open func setupSessionOutputs() ->Bool {
        
        return false
    }
    
    open func startSession() {
        
        dispatchQueue.async {[weak self] in
            if self!.captureSession.isRunning == false {
                self?.captureSession.startRunning()
            }
        }
    }
    
    open func stopSession() {
        dispatchQueue.async {[weak self] in
            if self!.captureSession.isRunning == false {
                self?.captureSession.startRunning()
            }
        }
    }
    
    ///////////////////////////摄像头配置///////////////////////////
    
    func camera(position: AVCaptureDevice.Position) ->AVCaptureDevice? {
        
        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        for device in devices {
            if device.position == position {
                return device
            }
        }
        
        return nil
    }
    
    // 激活的相机设备
    func activeCamera() ->AVCaptureDevice {
        
        return self.activeVideoInput.device
    }
    
    // 是否能切换摄像头
    func canSwitchCamera() ->Bool {
        
        return self.cameraCount() > 1
    }
    
    // 未激活的相机设备
    func inactiveCamera() ->AVCaptureDevice? {
        
        var device: AVCaptureDevice?
        
        if self.cameraCount() > 1 {
            
            if self.activeCamera().position == .back {
                device = self.camera(position: .front)
            } else {
                device = self.camera(position: .back)
            }
        }
        
        return device
    }
    
    func cameraCount() ->Int {
        
        return AVCaptureDevice.devices(for: AVMediaType.video).count
    }
    
    // 切换摄像头
    func switchCamera() ->Bool {
        
        if self.canSwitchCamera() == false {
            return false
        }
        
        let videoDevice = self.inactiveCamera()
        
        do {
            let videoInput = try AVCaptureDeviceInput.init(device: videoDevice!)
            
            captureSession.beginConfiguration()
            
            captureSession.removeInput(self.activeVideoInput)
            
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
                self.activeVideoInput = videoInput
            } else {
                self.captureSession.addInput(self.activeVideoInput)
            }
            
            if self.setupSessionOutputs() == false {
                NSLog("设置输出失败!")
            }
            
            self.captureSession.commitConfiguration()
        } catch let error {
            NSLog("switchCamera error: \(error.localizedDescription)")
            return false
        }
        
        return true
    }
    
}

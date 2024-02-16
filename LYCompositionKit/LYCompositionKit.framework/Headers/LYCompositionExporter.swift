//
//  LYCompositionExporter.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import AVFoundation

/** 回调 */
public protocol LYCompositionExporterDelegate:NSObjectProtocol {
    
    /** 回调导出进度 */
    func exportProgress(_ progress:CGFloat);
    /** 导出失败 */
    func exportFailed();
    /** 导出取消 */
    func exportCancelled()
    /** 导出完成 并返回视频的路径, 保存到相册后需要手动删除 */
    func exportCompleted(_ videoURL: URL!)
    
}

/** 合成导出 */
open class LYCompositionExporter: NSObject {
    
    open weak var delegate:LYCompositionExporterDelegate?;// 回调导出进度
    open var exporting:Bool = false;
    open var progress:CGFloat = 0.0;
    fileprivate var exportSession:AVAssetExportSession!
    fileprivate var monitorTimer:Timer!;
    
    public init(exportSession: AVAssetExportSession) {
        self.exportSession = exportSession
    }
    
    public init(composition: LYComposition, presetName: String? = nil) {
        if presetName == nil {
            self.exportSession = composition.makeExportable()
        } else {
            self.exportSession = composition.makeExportable(presetName!)
        }
    }
    
    /**
     * 开始导出
     * low~12% medium~30%
     */
    open func beginExport() {
        
        if self.exportSession == nil {
            self.delegate?.exportFailed()
            return
        }
        self.exportSession.outputURL = self.exportURL();
        self.exportSession.outputFileType = AVFileType.mp4;
        
        DLog("export url: \(String(describing: self.exportSession.outputURL?.absoluteString))")
        DLog("created exporter. supportedFileTypes: \(self.exportSession.supportedFileTypes)")
        
        let videoURL = self.exportSession.outputURL
        self.exportSession.exportAsynchronously(completionHandler: { [weak self] () -> Void in
            
            DispatchQueue.main.async(execute: { () -> Void in
                
                if self == nil {
                    return
                }
                
                let status = self!.exportSession.status;
                
                DLog("status: \(status.rawValue)")
                switch status {
                case .completed:
                    if(self?.progress != 1.0){// 保证完成回调在进度回调之后
                        self?.progress = 1.0;
                        if self != nil {
                            self?.delegate?.exportProgress(self!.progress);
                        }
                        self?.invalidateMonitorTimer();
                    }
                    // 回调
                    self?.delegate?.exportCompleted(videoURL)
                    break
                case .unknown:
                    break
                case .waiting:
                    break
                case .exporting:
                    break
                case .failed:
                    let error = self!.exportSession.error
                    if error != nil {
                        DLog("async export error: \(error!.localizedDescription)")
                    }
                    self?.invalidateMonitorTimer();
                    self?.delegate?.exportFailed()
                    break
                case .cancelled:
                    self?.invalidateMonitorTimer();
                    self?.delegate?.exportCancelled()
                    break
                @unknown default: break
                }
                
            });
        })
        
        self.exporting = true;
        self.monitorExportProgressForTimer();
        
    }
    
    /** 取消/停止导出 */
    open func stopExport() {
        
        self.exportSession.cancelExport()
    }
    
    /** 监听进度并回调到主线程控制器 秒跨度有点大,看不出进度提示*/
    fileprivate func monitorExportProgressForDispatch() {
        
        let delayInSeconds:CGFloat = 1;
        let delta = delayInSeconds * CGFloat(NSEC_PER_SEC);
        
        let popTime = DispatchTime.now() + Double(Int64(delta)) / Double(NSEC_PER_SEC);
        
        DispatchQueue.main.asyncAfter(deadline: popTime) { [weak self] in
            
            if self == nil {
                self?.delegate?.exportFailed();
                return
            }
            
            let status = self!.exportSession.status;
            if(status == .exporting){
                
                self?.progress = CGFloat(self!.exportSession.progress);
                self?.delegate?.exportProgress(self!.progress);
                
                self?.monitorExportProgressForDispatch();
            }
            
        }
        
    }
    
    @objc func exportProgress() {
        
        let status = self.exportSession?.status;
        if(status == .exporting){
            
            self.progress = CGFloat(self.exportSession!.progress);
            self.delegate?.exportProgress(self.progress);
            
            if(self.progress == 1.0){
                self.invalidateMonitorTimer();
            }
        }
        
    }
    
    fileprivate func monitorExportProgressForTimer() {
        
        self.monitorTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(exportProgress), userInfo: nil, repeats: true);
        
    }
    
    fileprivate func invalidateMonitorTimer() {
        
        if(self.monitorTimer != nil){
            self.monitorTimer.invalidate();
            self.monitorTimer = nil;
        }
        
    }
    
    /** 创建临时动态保存路径 */
    fileprivate func exportURL() ->URL {
        var filePath = NSTemporaryDirectory();
        repeat {
            filePath = NSTemporaryDirectory() + String(format: "video-%d.mp4",Int32(Date().timeIntervalSince1970));
        } while(FileManager.default.fileExists(atPath: filePath))
        let url = URL(fileURLWithPath: filePath);
        return url
    }
    
    /** 创建临时保存路径 */
    fileprivate func generateExportURL() ->URL {
        let filePath = NSTemporaryDirectory() + String(format: "video-export.mp4",Int32(Date().timeIntervalSince1970))
        if FileManager.default.fileExists(atPath: filePath) {
            try? FileManager.default.removeItem(atPath: filePath)
        }
        let url = URL(fileURLWithPath: filePath);
        return url
    }
    
}


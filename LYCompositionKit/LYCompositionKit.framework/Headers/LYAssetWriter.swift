//
//  LYAssetWriter.swift
//  LYCompositionKit
//
//  Created by tony on 2017/8/13.
//  Copyright © 2017年 chengkai. All rights reserved.
//

import UIKit
import AVFoundation

open class LYAssetWriter: NSObject {
    
    // 是否已经取消
    var isCancelled: Bool = false
    var assetWriter: AVAssetWriter!
    
    open class func shared() ->LYAssetWriter {
        
        struct Static {
            static let instance = LYAssetWriter()
        }
        
        return Static.instance
    }
    
    /**
     * 反转视频
     * 异步执行
     * timeRange: 原始视频的时间范围, 为空反转整个视频
     * 返回-1: 代表导出错误 -2: 代表取消 
     * true: 代表执行完成 false: 导出失败或者取消
     */
    open func reverseAsync(_ original: AVAsset, timeRange: CMTimeRange?, outputURL: URL?, isRemainder: Bool, completion: @escaping (Double, Bool, URL) -> Void) {
        
        DispatchQueue.global().async {[weak self] in
            self?.reverse(original, timeRange: timeRange, outputURL: outputURL, isRemainder: isRemainder, completion: completion)
        }
    }
    
    /**
     * 反转视频, 返回进度和路径
     * 同步执行
     * timeRange: 原始视频的时间范围, 为空反转整个视频
     * 返回-1: 代表导出错误 true: 代表执行完成
     */
    open func reverse(_ original: AVAsset, timeRange: CMTimeRange?, outputURL: URL?, isRemainder: Bool, completion: @escaping (Double, Bool, URL) -> Void) {
        
        var videoURL: URL! = outputURL
        if videoURL == nil {
            videoURL = reverseURL()
        }
        guard let _ = original.tracks(withMediaType: AVMediaType.video).last else {
            DLog("could not retrieve the video track.")
            DispatchQueue.main.async {
                
                completion(-1, true, videoURL)
            }
            return
        }
        
        var targetTimeRange: CMTimeRange = CMTimeRange(start: CMTime.zero, duration: original.duration)
        if let timeRange = timeRange {
            targetTimeRange = timeRange
        }
        
        // targetTimeRange = CMTimeRange(start: CMTime(value: 300, timescale: 30), duration: CMTime(value: 180, timescale: 30))
        let timeScale: Int32 = 30
        let timeRanges = calculateTimeRanges(timeRange: targetTimeRange, timeScale: timeScale, divideSeconds: 1, isRemainder: isRemainder)
        
        // Initialize the writer
        let writer: AVAssetWriter
        do {
            writer = try AVAssetWriter(outputURL: videoURL, fileType: AVFileType.mp4)
        } catch let error {
            //fatalError(error.localizedDescription)
            DLog("error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                
                completion(-1, true, videoURL)
            }
            return
        }
        
        LYAssetWriter.shared().assetWriter = writer
        LYAssetWriter.shared().isCancelled = false
        
        var isStarting: Bool = false
        var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor!
        var writerInput: AVAssetWriterInput!
        
        var previousTime: Int64 = 0
        
        
        for (indexTimeRange, _) in timeRanges.enumerated() {
            
            // 倒序取出时间段的样本
            let reverseIndex = timeRanges.count - 1 - indexTimeRange
            let nextTimeRange = timeRanges[reverseIndex]
            if let (videoTrack, samples) = calculateOriginalSamples(original: original, timeRange: nextTimeRange, timeScale: timeScale) {
                
                if isStarting == false {
                    let videoCompositionProps = [AVVideoAverageBitRateKey: videoTrack.estimatedDataRate]
                    // 这里需要得到实际宽高
                    let writerOutputSettings = [
                        AVVideoCodecKey: AVVideoCodecH264,
                        AVVideoWidthKey: videoTrack.naturalWidth,
                        AVVideoHeightKey: videoTrack.naturalHeight,
                        AVVideoCompressionPropertiesKey: videoCompositionProps
                        ] as [String : Any]
                    
                    // add input
                    writerInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: writerOutputSettings)
                    writerInput.expectsMediaDataInRealTime = false
                    //writerInput.transform = compositionTrack.preferredTransform
                    
                    pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: nil)
                    
                    writer.add(writerInput)
                    writer.startWriting()
                    
                    writer.startSession(atSourceTime: CMTime.zero)
                    isStarting = true
                }
                // 用于计量累计插入时间帧
                var timeValue: Int64 = 0
                for (index, sample) in samples.enumerated() {
                    
                    if LYAssetWriter.shared().isCancelled {
                        
                        DispatchQueue.main.async {
                            
                            writerInput.markAsFinished()
                            writer.cancelWriting()
                            LYAssetWriter.shared().assetWriter = nil
                            completion(-2, false, videoURL)
                        }
                        return
                    }
                    
                    if timeValue == timeScale {// 超出的样本直接过滤掉
                        break
                    }
                    // 此处正确计算样本时间
                    // 获取当前时间未知
                    var presentationTime = CMSampleBufferGetPresentationTimeStamp(sample)

                    // 此处计算出的时间必须是顺序的
                    // let value = presentationTime.value % Int64(presentationTime.timescale) * Int64(timeScale) / Int64(presentationTime.timescale)
                    
                    DLog("Time.value: \(timeValue)  \(indexTimeRange) | \(reverseIndex) | \(presentationTime)")
                    //DLog("读取时间:  \(value)  \(presentationTime)")
                    presentationTime = CMTime(value: timeValue + Int64(indexTimeRange) * Int64(timeScale), timescale: timeScale)
                    //presentationTime = CMTime(value: value + Int64(previousTime), timescale: timeScale)
                    DLog("当前时间:  \(timeValue)  \(presentationTime)")
                    // 倒序获取样本
                    let imageBufferRef = CMSampleBufferGetImageBuffer(samples[samples.count - 1 - index])
                    while !writerInput.isReadyForMoreMediaData {
                        Thread.sleep(forTimeInterval: 0.1)
                    }
                    
                    // 至少写入一秒
                    pixelBufferAdaptor.append(imageBufferRef!, withPresentationTime: presentationTime)
                    
                    timeValue += 1
                    DispatchQueue.main.async {
                        
                        let progress = Double(indexTimeRange * Int(timeScale) + index) / Double(timeRanges.count * Int(timeScale))
                        completion(progress, false, videoURL)
                    }
                }
                
                
                previousTime = previousTime + Int64(samples.count)
            }
            
        }
        
        DispatchQueue.main.async {
            completion(1, false, videoURL)
        }
        
        writerInput.markAsFinished()
        writer.finishWriting {
            // 释放写入器
            LYAssetWriter.shared().assetWriter = nil
            DispatchQueue.main.async {
                completion(1, true, videoURL)
            }
        }
    }
    
    /// 取消写入
    open func cancel() {
        
        LYAssetWriter.shared().isCancelled = true
    }
    
    // 计算出样本数据
    private func calculateSamples(original: AVAsset, timeRange: CMTimeRange, timeScale: Int32) -> (AVMutableCompositionTrack, [CMSampleBuffer])? {
        
        guard let videoTrack = original.tracks(withMediaType: AVMediaType.video).last else {
            DLog("could not retrieve the video track.")
            return nil
        }
        
        let composition = AVMutableComposition()
        let compositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        compositionTrack?.preferredTransform = videoTrack.preferredTransform
        
        // 计算出不同的时间段
        do {
            try compositionTrack?.insertTimeRange(timeRange, of: videoTrack, at: CMTime.zero)
        } catch let error {
            DLog("insertTimeRange error: \(error.localizedDescription)")
        }
        
        // Initialize the reader
        var reader: AVAssetReader! = nil
        do {
            reader = try AVAssetReader(asset: composition)
        } catch {
            DLog("could not initialize reader.")
            return nil
        }
        
        reader.timeRange = CMTimeRange(start: CMTime.zero, duration: CMTime(value: composition.duration.value, timescale: composition.duration.timescale))
        
        // set to YUV420 -- 必须设置成未压缩格式, 否则会初始化失败
        let readerOutputSettings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        // let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: readerOutputSettings)
        
        let readerOutput = AVAssetReaderVideoCompositionOutput(videoTracks: [compositionTrack!], videoSettings: readerOutputSettings)
        
        let videoComposition = AVMutableVideoComposition(propertiesOf: original)
        videoComposition.frameDuration = CMTime(value: 1, timescale: timeScale)
        //videoComposition.instructions = [instruction]
        readerOutput.videoComposition = videoComposition
        readerOutput.alwaysCopiesSampleData = false
        reader.add(readerOutput)
        
        reader.startReading()
        
        // read in samples
        var samples: [CMSampleBuffer] = []
        while let sample = readerOutput.copyNextSampleBuffer() {
            samples.append(sample)
        }
        
        return (compositionTrack, samples) as? (AVMutableCompositionTrack, [CMSampleBuffer])
    }
    
    // 计算出样本数据
    private func calculateOriginalSamples(original: AVAsset, timeRange: CMTimeRange, timeScale: Int32) -> (AVAssetTrack, [CMSampleBuffer])? {
        
        guard let videoTrack = original.tracks(withMediaType: AVMediaType.video).last else {
            DLog("could not retrieve the video track.")
            return nil
        }

        var reader: AVAssetReader! = nil
        do {
            reader = try AVAssetReader(asset: original)
        } catch {
            DLog("could not initialize reader.")
            return nil
        }
        
        //DLog("original timeRange: \(CMTimeGetSeconds(timeRange.start))   \(CMTimeGetSeconds(timeRange.duration))")
        reader.timeRange = timeRange
        
        // set to YUV420 -- 必须设置成未压缩格式, 否则会初始化失败
        let readerOutputSettings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]

        let readerOutput = AVAssetReaderVideoCompositionOutput(videoTracks: [videoTrack], videoSettings: readerOutputSettings)
        
        let videoComposition = AVMutableVideoComposition(propertiesOf: original)
        videoComposition.frameDuration = CMTime(value: 1, timescale: timeScale)
        //videoComposition.instructions = [instruction]
        readerOutput.videoComposition = videoComposition
        readerOutput.alwaysCopiesSampleData = false
        
        reader.add(readerOutput)
        
        reader.startReading()
        
        // read in samples
        var samples: [CMSampleBuffer] = []
        // 此处读取的样本数可能会出错，需要控制固定的样本数
        while let sample = readerOutput.copyNextSampleBuffer() {
            
            samples.append(sample)
        }
        
//        repeat {// 如果大于指定样本数则删除第一个
//            samples.removeFirst()
//        } while samples.count > timeScale
        
        return (videoTrack, samples)
    }
    
    // 计算分段的时间范围
    private func calculateTimeRanges(timeRange: CMTimeRange, timeScale: Int32, divideSeconds: Int32, isRemainder: Bool) -> [CMTimeRange] {
        
        // 视频的开始时间
        let startTime: CMTime = timeRange.start
        let duration: CMTime = timeRange.duration
        
        // 计算切割次数 按1秒 30帧/秒计算切割次数 -- 计算出帧数
        let frameCount = Int32(duration.value * Int64(timeScale) / Int64(duration.timescale))
        
        let startTimeValue = startTime.value * Int64(timeScale) / Int64(startTime.timescale)
        // 计算单次递增的秒数
        let secondDelta = timeScale * divideSeconds
        // 计算切割次数
        let remainder = frameCount % secondDelta
        let divideCount = frameCount / secondDelta
        
        var timeRanges: [CMTimeRange] = []
        for index in 0 ..< divideCount {// 计算一个timeRange出来
            
            let timeRange = CMTimeRangeMake(start: CMTime(value: Int64(index * secondDelta) + startTimeValue, timescale: timeScale), duration: CMTime(value: Int64(secondDelta), timescale: timeScale))
            timeRanges.append(timeRange)
        }
        
        if isRemainder && remainder != 0 {
            let timeRange = CMTimeRangeMake(start: CMTime(value: Int64(divideCount * secondDelta), timescale: timeScale), duration: CMTime(value: Int64(remainder), timescale: timeScale))
            timeRanges.append(timeRange)
        }
        
        return timeRanges
    }
    
    /** 创建临时保存路径 */
    private func reverseURL() ->URL {
        
        let filePath = NSTemporaryDirectory() + String(format: "video-reverse.mp4")
        
        DLog("文件路径: \(filePath)")
        if FileManager.default.fileExists(atPath: filePath) {
            do {
                try FileManager.default.removeItem(atPath: filePath)
            } catch let error {
                DLog("error: \(error.localizedDescription)")
            }
        }
        
        let url = URL(fileURLWithPath: filePath);
        
        return url;
    }
    
}

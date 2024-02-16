//
//  LYTimelineView.swift
//  LineVideo
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkaizone. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia
import Photos

// 请求的图片帧
private class FrameItem {
    
    /** 提取的时间 */
    fileprivate var requestedTime: CMTime!
    
    fileprivate var mediaType: PHAssetMediaType!
    
    fileprivate var localIdentifier: String!
    
}

/// 时间回调
@objc public protocol LYTimelineViewDelegate: NSObjectProtocol {
    
    /// load done
    func timelineViewDidLoadDone(_ timelineView: LYTimelineView);
    
    /// 滑动指向的时间点
    func timelineView(_ timelineView: LYTimelineView, didSeekToTime time: TimeInterval);
    
    /// 指向的选区回调
    func timelineView(_ timelineView: LYTimelineView, didChangeSelection selection: LYTimelineSelection);
    
    /// 拖动时间轴
    func timelineViewWillBeginDragging(_ timelineView: LYTimelineView);
    
    /// 拖动时间轴结束
    func timelineViewDidEndDragging(_ timelineView: LYTimelineView)
    
    /// 滚动结束
    func timelineViewDidEndDecelerating(_ timelineView: LYTimelineView)
    
    /// 添加时间段达到结束位置
    func timelineViewReachEnd(_ timelineView: LYTimelineView);
    
}

/**
 * 视频时间线视图 -- 默认允许同一时间添加多个选区
 */
open class LYTimelineView: UIView {
    
    fileprivate var displayer: ImageDisplayer?
    
    /// 允许添加的最短时间
    fileprivate var minimumTime:TimeInterval!
    /// 计算出最小空间(像素/点) 对应最短时长
    fileprivate var minimumSpace: CGFloat = 0
 
    /// 是否处于拖动添加选区
    open var dragScroll: Bool = false
    
    fileprivate var viewTotalWidth: CGFloat = 0
    
    /// 是否允许多层添加 default is true
    open var multiplyEnabled: Bool = true
    /// 是否允许从起始点裁剪片段 字幕和表情都允许(音乐不行) default is true
    open var trimStartEnabled: Bool = true
    /// 下次添加最终到达的时间点 multiplyEnabled = false 有效
    fileprivate var reachNearestTime: TimeInterval = 0
    // 编辑选区时最能达到最左边的时间点
    fileprivate var startNearestTime: TimeInterval = 0
    
    // 允许的容差时间值
    fileprivate let allowanceTime: TimeInterval = 0.15
    
    // 提取第一张之后作为站位图片
    fileprivate var placeholderCGImage: CGImage!
    fileprivate var requestFrames: [FrameItem]!
    
    // 图片提取工具
    fileprivate var imageGenerator:AVAssetImageGenerator!;
    fileprivate var videoComposition: AVVideoComposition?
    
    // 创建一个串行队列, 用于顺序加载图片
    fileprivate var dispatchQueue: DispatchQueue!
    
    open var asset: AVAsset!
    
    // 传递timeline, 处理包含图片合成的情况
    open var timeline: LYTimeline!
    
    //MARK: - init
    public init(frame: CGRect, timeline: LYTimeline!, asset: AVAsset, videoComposition: AVVideoComposition?, cellSize: CGSize, totalDuration: TimeInterval, unitDuration: TimeInterval, minimumTime: TimeInterval, delegate: LYTimelineViewDelegate?, displayer: ImageDisplayer?) {
        super.init(frame: frame);
        
        self.dispatchQueue = DispatchQueue(label: "DISPATCH_QUEUE_SERIAL.timelineView", attributes: [])
        self.delegate = delegate;
        
        self.displayer = displayer
        
        self.timeline = timeline
        self.asset = asset
        self.videoComposition = videoComposition
        
        self.minimumTime = minimumTime
        
        self.totalDuration = totalDuration
        self.unitDuration = unitDuration
        
        self.minimumSpace = cellSize.width / CGFloat(unitDuration) * CGFloat(minimumTime)
        
        let (requestFrames, remainder) = self.generatorFrameItems()
        self.requestFrames = requestFrames
        viewTotalWidth = cellSize.width * CGFloat(totalDuration / unitDuration)
        
        let collectionViewFrame = CGRect(x: 0, y: (frame.height - cellSize.height) / 2, width: frame.width, height: cellSize.height);
        
        let flowLayout = LYTimelineViewFlowLayout();
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0
        flowLayout.itemSize = cellSize
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = defaultSectionInset(frame)
        
        if remainder == 0 {
            flowLayout.lastIntegral = true
        } else {
            flowLayout.lastIntegral = false
            flowLayout.lastWidthRatio = remainder
        }
        
        self.collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FrameCell.self, forCellWithReuseIdentifier: "frameCell")
        collectionView.backgroundColor = UIColor.clear
        collectionView.bounces = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        collectionView.contentSize = CGSize(width: frame.width * 2, height: cellSize.height)
        
        addSubview(collectionView)
        
        // lineView
        lineView = UIView(frame: CGRect(x: 0, y: 0, width: 2, height: frame.height))
        lineView.center = CGPoint(x: frame.width / 2, y: frame.height / 2)
        lineView.backgroundColor = UIColor(red: 1.0, green: 100.0 / 255.0, blue: 56.0 / 255.0, alpha: 1.0)
        lineView.layer.cornerRadius = 2
        addSubview(lineView!)
        
        linePositionX = lineView!.center.x
        
        self.imageGenerator = self.createImageGenerator(asset, videoComposition: videoComposition)
    }
    
    open override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.adjustSubviewsFrame()
    }
    
    // 自身是否调整完成
    fileprivate var layoutComplete: Bool = false
    fileprivate func adjustSubviewsFrame() {
        if layoutComplete {
            return
        }
        
        layoutComplete = true
        
        let (requestFrames, remainder) = self.generatorFrameItems()
        self.requestFrames = requestFrames
        
        let flowLayout = self.flowLayout() as! LYTimelineViewFlowLayout
        let cellSize = flowLayout.itemSize
        viewTotalWidth = cellSize.width * CGFloat(totalDuration / unitDuration)
        
        let collectionViewFrame = CGRect(x: 0, y: (frame.height - cellSize.height) / 2, width: frame.width, height: cellSize.height);
    
        flowLayout.sectionInset = defaultSectionInset(frame)
        
        if remainder == 0 {
            flowLayout.lastIntegral = true
        } else {
            flowLayout.lastIntegral = false
            flowLayout.lastWidthRatio = remainder
        }
        
        self.collectionView.frame = collectionViewFrame
        
        lineView.frame = CGRect(x: 0, y: 0, width: 2, height: frame.height)
        lineView.center = CGPoint(x: frame.width / 2, y: frame.height / 2)
        
        linePositionX = lineView!.center.x
        
        self.prepareData()
        
        self.delegate?.timelineViewDidLoadDone(self)
    }
    
    /**
     * 创建图片生成器
     */
    fileprivate func createImageGenerator(_ asset: AVAsset, videoComposition: AVVideoComposition?) ->AVAssetImageGenerator {
        let imageGenerator = AVAssetImageGenerator(asset: asset);
        imageGenerator.videoComposition = videoComposition
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceBefore = CMTimeMake(value: 1, timescale: 600)
        imageGenerator.requestedTimeToleranceAfter = CMTimeMake(value: 1, timescale: 600)
        // 自动配置宽高比
        imageGenerator.maximumSize = CGSize(width: self.frame.height * UIScreen.main.scale, height: 0)
        
        return imageGenerator
    }
    
    /** 准备图片数据显示 */
    fileprivate func prepareData() {
        let cellSize = flowLayout().itemSize
        self.collectionView.reloadData()
        self.collectionView.contentSize = CGSize(width: self.frame.width * 2, height: cellSize.height)
        
        if timeline != nil {
            let videoItem = timeline.requestItem(CMTime: CMTime.zero)
            
            if videoItem.mediaType == .image {
                let phAsset = PHAsset.fetchAsset(localIdentifier: videoItem.localIdentifier)
                self.placeholderCGImage = phAsset?.image(targetSize: cellSize)?.cgImage
            } else {
                var actualTime = CMTime.zero
                self.placeholderCGImage = try? self.imageGenerator.copyCGImage(at: copyFirstTime, actualTime: &actualTime)
            }
        } else {
            var actualTime = CMTime.zero
            self.placeholderCGImage = try? self.imageGenerator.copyCGImage(at: copyFirstTime, actualTime: &actualTime)
        }
        
    }
    
    /** 生成需要提取的时间, 以及余数(一帧的百分比宽度) */
    fileprivate func generatorFrameItems() ->([FrameItem], CGFloat) {
        
        var frameItems = [FrameItem]();
        
        // 计算出需要提取的帧数
        let frames = CGFloat(totalDuration / unitDuration)
        let unitTime = CMTimeMake(value: Int64(unitDuration), timescale: 1);
        
        // 计算出小数部分的帧数, 一帧的百分比
        var remainder = frames - floor(frames)
        var count = Int64(frames)
        if (remainder * 100) < 2 {// < 0.02的情况就不需要绘制了
            remainder = 0
            count -= 1
        }
        
        for i:Int64 in 0...count {
            
            let tmpTime = CMTimeMake(value: unitTime.value * i, timescale: unitTime.timescale);
            
            let frameItem = FrameItem()
            frameItem.requestedTime = tmpTime
            
            if self.timeline != nil {
                let videoItem = self.timeline.requestItem(CMTime: tmpTime)
                frameItem.mediaType = videoItem.mediaType
                frameItem.localIdentifier = videoItem.localIdentifier
            } else {
                frameItem.mediaType = .video
                
            }
            
            frameItems.append(frameItem)
        }
        
        return (frameItems, remainder)
    }
    
    /** 
     * 递归提取占位图片
     */
    fileprivate func extractCGImage(_ time: CMTime) ->CGImage! {
        
        do {
            var actualTime = CMTime.zero
            
            var copyTime = time
            if copyTime == CMTime.zero {
                copyTime = copyFirstTime
            }
            let cgImage = try self.imageGenerator.copyCGImage(at: copyTime, actualTime: &actualTime)
            return cgImage
        } catch let error as NSError {
            DLog("prepareData generator error: \(error.description)")
        }
        
        let duration = CMTimeGetSeconds(self.asset.duration)
        // 每次进位1%提取
        let stepTime = CMTimeMakeWithSeconds(duration * 0.01, preferredTimescale: time.timescale)
        let nextTime = CMTimeAdd(time, stepTime)
        
        if CMTimeCompare(nextTime, self.asset.duration) == 1 {
            return nil
        }
        
        return extractCGImage(nextTime)
    }
    
    fileprivate func flowLayout() ->UICollectionViewFlowLayout {
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    // 获取默认边距
    fileprivate func defaultSectionInset(_ frame: CGRect) ->UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: frame.width / 2, bottom: 0, right: frame.width / 2)
    }
    
    //MARK: property
    fileprivate var collectionView: UICollectionView!;
    fileprivate weak var delegate: LYTimelineViewDelegate?;
    fileprivate var totalDuration: TimeInterval!;
    // 一帧的单位时长
    fileprivate var unitDuration: TimeInterval!
    
    fileprivate var selectionViews = [LYTimelineSelection : UIView]();
    open var selections: [LYTimelineSelection]? {
        if selectionViews.keys.count == 0 {
            return nil
        }
        
        var selections = [LYTimelineSelection]()
        for selection in selectionViews.keys {
            selections.append(selection)
        }
        
        return selections
    }
    
    // 时间线状态
    fileprivate(set) var currentStatus: LYTimelineViewStatus = .normal;
    
    // 中间指向当前时间的白线
    fileprivate var lineView: UIView!;
    fileprivate var linePositionX: CGFloat = 0 {
        didSet {
            lineView?.frame.origin.x = linePositionX;
            updateDisplayTime();
        }
    }
    
    fileprivate var shouldUpdateTimeWithScroll = true
    // 滚动偏移量
    fileprivate var scrollOffset: CGFloat = 0 {
        didSet {
            if shouldUpdateTimeWithScroll {
                updateDisplayTime();
            }
        }
    }
    
    fileprivate var shouldUpdateAdding = true
    fileprivate var shouldUpdateSeekTime = true
    /// 当前时间
    open var currentTime: TimeInterval = 0 {
        didSet {
            if shouldUpdateAdding {
                updateAddingSelection();
            }
            
            if shouldUpdateSeekTime {
                self.delegate?.timelineView(self, didSeekToTime: currentTime);
            } else {
                shouldUpdateSeekTime = true
            }
            
        }
    }
    
    fileprivate var addingSelection: LYTimelineSelection?
    fileprivate var currentAddingView: UIView?
    // 是否允许到达最大值后自动结束 -- 默认true
    fileprivate var autoReachEnd: Bool = true
    
    fileprivate var editingSelection: LYTimelineSelection?
    fileprivate var currentSliderView: LYSliderView?
    
    open var leftSliderImageName: String?
    open var leftSliderImageNameHighlighted: String?
    open var rightSliderImageName: String?
    open var rightSliderImageNameHighlighted: String?
    open var sliderViewBackgroundColor: UIColor = UIColor.clear
    
    /**
     * 从指定时间开始添加一个新的时间段 --- 状态 不正确不允许添加
     * 0:添加成功 1:添加空间不足 2:当前状态不允许添加 3 当前有片段不允许添加
     */
    open func addSelection(_ startTime: TimeInterval) ->(Int, LYTimelineSelection?) {
        guard currentStatus == .normal else {
            return (2, nil)
        }
        
        if multiplyEnabled {
            if totalDuration - currentTime < minimumTime {
                
                return (1, nil)
            }
        } else {// 检查该时间点是否有选区以及离下一个选区的空间是否足够
            // 计算出开始时间大于当前时间且最接近当前时间的值
            reachNearestTime = totalDuration
            for (selection, _) in selectionViews {
                
                if selection.containTime(currentTime){
                    
                    return (3, nil)
                } else {
                    if selection.startTime > currentTime {
                        reachNearestTime = min(reachNearestTime, selection.startTime)
                    }
                }
            }
            
            if reachNearestTime - currentTime <  minimumTime {
                return (1, nil)
            }
        }
        reachNearestTime -= allowanceTime
        
        let selection = LYTimelineSelection(startTime: startTime, duration: 0)
        currentAddingView = addSelection(selection, isDelay: true)
        currentStatus = .adding
        addingSelection = selection
        
        return (0, selection)
    }
    
    // 确定添加时间段
    open func confirmAddSelection() ->LYTimelineSelection? {
        guard let addingSelection = addingSelection , currentStatus == .adding else {
            return nil
        }
        
        currentStatus = .normal
        autoReachEnd = true
        
        currentAddingView = nil
        self.addingSelection = nil
        
        return addingSelection
    }
    
    // 取消添加时间段
    open func cancelAddSelection() {
        guard let addingSelection = addingSelection , currentStatus == .adding else {
            return
        }
        
        currentStatus = .normal
        
        if let addingView = currentAddingView {
            addingView.removeFromSuperview()
            currentAddingView = nil;
            self.addingSelection = nil
        }
        
        selectionViews.removeValue(forKey: addingSelection)
    }
    
    //MARK: edit 编辑一个片段
    open func editingSelection(_ selection: LYTimelineSelection) {
        guard let view = selectionViews[selection] , currentStatus == .normal else {
            return
        }
        
        editingSelection = selection
        currentStatus = .editing
        
        let layout = flowLayout()
        
        var leftEdge = layout.sectionInset.left
        var rightEdge = layout.sectionInset.left + viewTotalWidth
        if multiplyEnabled == false {
            reachNearestTime = totalDuration
            startNearestTime = 0
            
            for (selectionp, _) in selectionViews {
                if selectionp != selection {
                    if selectionp.startTime >= selection.endTime {
                        reachNearestTime = min(reachNearestTime, selectionp.startTime)
                    }
                    
                    if selectionp.endTime <= selection.startTime {
                        startNearestTime = max(startNearestTime, selectionp.endTime)
                    }
                } else {
                    
                }
                
            }
            
            if reachNearestTime == totalDuration {
                rightEdge = layout.sectionInset.left + viewTotalWidth
            } else {
                reachNearestTime -= allowanceTime
                rightEdge = layout.sectionInset.left + viewTotalWidth * CGFloat(reachNearestTime / totalDuration)
            }
            
            if startNearestTime == 0 {
                leftEdge = layout.sectionInset.left
            } else {
                startNearestTime += allowanceTime
                leftEdge = layout.sectionInset.left + viewTotalWidth * CGFloat(startNearestTime / totalDuration)
            }
        }
        
        // 视图的frame范围
        let rangeRect = CGRect(x: leftEdge, y: 0, width: rightEdge, height: 1)
        
        let sliderView = LYSliderView(frame: view.frame.insetBy(dx: -LYSliderView.sliderWidth, dy: 0), rangeRect: rangeRect, delegate: self)
        
        sliderView.setSliderImage(sliderView.leftSlider, imageName: leftSliderImageName, hightlightedName: leftSliderImageNameHighlighted)
        sliderView.setSliderImage(sliderView.rightSlider, imageName: rightSliderImageName, hightlightedName: rightSliderImageNameHighlighted)
        
        collectionView.addSubview(sliderView)
        currentSliderView = sliderView
    }
    
    open func confirmEditing() ->LYTimelineSelection? {
        guard let editingSelection = editingSelection , currentStatus == .editing else{
            return nil
        }
        
        currentStatus = .normal
        
        if let sliderView = currentSliderView {
            sliderView.removeFromSuperview()
            currentSliderView = nil
        }
        
        return editingSelection
    }
    
    /// 删除正在编辑的时间段
    open func deleteEditing() {
        guard let selection = editingSelection, let view = selectionViews[selection], let sliderView = currentSliderView , currentStatus == .editing else {
            return
        }
        
        view.removeFromSuperview()
        selectionViews.removeValue(forKey: selection)
        sliderView.removeFromSuperview()
        
        currentSliderView = nil
        
        currentStatus = .normal
    }
    
    /// 查找指定时间是否有对应的选区
    open func containSelection(_ time: TimeInterval) ->LYTimelineSelection? {
        
        if let selections = selections {
            
            for selection in selections {
                if selection.containTime(time) {
                    return selection
                }
            }
        }
        
        return nil
    }
    
    /// 清空所有选区
    open func clearSelections() {
        
        for (selection, view) in selectionViews {
            view.removeFromSuperview()
            selectionViews.removeValue(forKey: selection)
        }
        
        if currentStatus == .editing {
            
            if currentSliderView != nil {
                currentSliderView?.removeFromSuperview()
            }
            currentSliderView = nil
            currentStatus = .normal
        }
        
    }
    
    /// 删除指定片段
    open func deleteSelection(_ selection: LYTimelineSelection) ->Bool {
        if selectionViews.keys.contains(selection) {
            let view = selectionViews[selection]
            if view != nil {
                view!.removeFromSuperview()
            }
            
            selectionViews.removeValue(forKey: selection)
            return true
        }
        
        return false
    }
    
    //MARK: add 添加时间段
    open func addSelections(_ selections: [LYTimelineSelection]) ->[LYTimelineSelection] {
        var newSelections = [LYTimelineSelection]()
        for selection in selections {
            let view = addSelection(selection, isDelay: false)
            if view != nil {
                newSelections.append(selection)
            }
        }
        
        return newSelections
    }
    
    /** 添加一个时间段 isDelay 是否延迟添加 */
    open func addSelection(_ selection: LYTimelineSelection, isDelay: Bool) ->UIView? {
        let positionLeft = positionXInCollectionOfTime(selection.startTime)
        
        if selection.duration > self.totalDuration - selection.startTime {
            selection.duration = self.totalDuration - selection.startTime
        }
        
        if !isDelay {
            if selection.duration < minimumTime {
                return nil
            }
        }
        
        let positionRight = positionXInCollectionOfTime(selection.endTime)
        
        
        let view = UIView(frame: CGRect(x: positionLeft, y: 0, width: positionRight - positionLeft, height: collectionView.frame.height))
        view.backgroundColor = UIColor.orange
        view.alpha = 0.6
        
        collectionView.addSubview(view)
        selectionViews[selection] = view
        
        return view
    }
    
    // 指向下一个可以开始添加的时间点
    open func seekNextTime() {
        currentTime += allowanceTime
    }
    
    // 时间轴到达最右边
    open func timeReachEnd(_ time: TimeInterval) {
        let layout = flowLayout()
        if time == totalDuration {
            collectionView.contentOffset.x = collectionView.contentSize.width - layout.sectionInset.left - layout.sectionInset.right
        } else{
            collectionView.contentOffset.x = deltaXInCollectionOfTime(reachNearestTime)
        }
    }
    
    //MARK: position --- 这里更新当前位置不需要回调
    open func updateCurrentTime(_ seekTime: TimeInterval) {
        // 这里更新当前位置的话不能回调
        shouldUpdateSeekTime = false
        
        switch currentStatus {
        case .normal, .editing:// 更新偏移量来更新当前时间 必须更新当前时间
            collectionView.contentOffset.x = collectionView.contentOffset.x + deltaXInCollectionOfTime(seekTime - currentTime)
            break;
        case .adding:
            checkAddingView(seekTime)
            break;
        }
    }
    
    // 校准之后检查添加块 --- bug?
    fileprivate func checkAddingView(_ seekTime: TimeInterval) {
        if currentStatus != .adding {
            return
        }
        
        if let addingSelection = addingSelection, let addingView = currentAddingView {
            var updateTime = seekTime
            if seekTime < currentTime {
                updateTime = currentTime
            }
            
            /// 这里的当前时间没有及时更新所致
            addingSelection.duration = updateTime - addingSelection.startTime
            
            /// 依赖移动计算的误差太多
            let deltaX = deltaXInCollectionOfTime(updateTime)
            collectionView.contentOffset.x = deltaX
            
            var frame = addingView.frame
            frame.size.width = deltaXInCollectionOfTime(addingSelection.duration)
            addingView.frame = frame
            
        }
    }
    
    // 移动到左边 --- 有一种特殊情况---只允许调整起始点时,宽度是不改变的
    fileprivate func moveLeftEdgeOfRect(_ rect: CGRect, dx: CGFloat, isSlider: Bool) ->CGRect {
        var rect = rect;
        
        if trimStartEnabled {
            rect.origin.x += dx
            rect.size.width -= dx
        } else {
            rect.origin.x += dx
            
            if currentSliderView != nil {
                let deltaWidth = isSlider ? LYSliderView.sliderWidth : 0
                let layout = flowLayout()
                let maxOrigin = layout.sectionInset.left + viewTotalWidth + deltaWidth - rect.size.width
                if rect.origin.x > maxOrigin {
                    rect.origin.x = maxOrigin
                }
            }
            
        }
        
        return rect
    }
    
    fileprivate func moveRightEdgeOfRect(_ rect: CGRect, dx: CGFloat) ->CGRect {
        var rect = rect;
        rect.size.width += dx
        
        return rect
    }
    
    // 获取时间点在collection集合视图中的差值
    fileprivate func deltaXInCollectionOfTime(_ time: TimeInterval) ->CGFloat {
        
        return viewTotalWidth * CGFloat(time / totalDuration)
    }
    
    // 获取时间点在容器视图中的X原点坐标
    fileprivate func positionXInCollectionOfTime(_ time: TimeInterval) ->CGFloat {
        
        return deltaXInCollectionOfTime(time) + flowLayout().sectionInset.left
    }
    
    // 计算坐标点在容器视图中对应的时间
    fileprivate func timeOfPositionXInCollectionOfTime(_ positionX: CGFloat) ->TimeInterval {
        
        return totalDuration * TimeInterval((positionX - flowLayout().sectionInset.left) / viewTotalWidth)
    }
    
    /// 更新当前时间
    fileprivate func updateDisplayTime() {
        let deltaX = scrollOffset - frame.width / 2 + linePositionX
        
        currentTime = Double(deltaX / viewTotalWidth) * totalDuration
    }
    
    // 更新添加的时间段
    fileprivate func updateAddingSelection() {
        if let addingSelection = addingSelection, let addingView = currentAddingView , currentStatus == .adding {
            
            var reachTime = totalDuration
            if multiplyEnabled == false {
                reachTime = reachNearestTime
            }
            
            var isReachEnd = false
            
            // 这里总是会有一定的误差--- 舍入引起的误差需要剔出
            if currentTime >= reachTime! || (reachTime! - currentTime) < 0.02 {
                shouldUpdateAdding = false
                currentTime = reachTime!
                timeReachEnd(reachTime!)
                shouldUpdateAdding = true
                isReachEnd = true
            }
            
            let newDuration = currentTime - addingSelection.startTime
            addingSelection.duration = newDuration
            let addWidth = flowLayout().itemSize.width * CGFloat(newDuration / 3)
            addingView.frame.size.width = addWidth
            
            if isReachEnd && autoReachEnd {
                DLog("updateAdding: YES")
                self.delegate?.timelineViewReachEnd(self)
            }
        }
    }
    
    //MARK: - scroll --- 滚动后
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        checkScrollOffset(scrollView)
    }
    
    //MARK: 检测偏移量
    fileprivate func checkScrollOffset(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        if let addingView = currentAddingView {// 处于添加选区中
            var delta: CGFloat = 2.0
            if dragScroll {
                delta = minimumSpace
            }
            
            // 最左边的位置
            let minOffset = delta + addingView.frame.minX - scrollView.frame.width / 2
            if offset < minOffset {
                scrollView.contentOffset.x = minOffset
                return
            }
        }
        
        scrollOffset = offset
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        if currentStatus == .adding {
            autoReachEnd = false
            dragScroll = true
        }
        
        self.delegate?.timelineViewWillBeginDragging(self)
    }
    
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

    }
    
    fileprivate func checkCurrentTime(_ scrollView: UIScrollView) {
        shouldUpdateTimeWithScroll = false
        scrollOffset = scrollView.contentOffset.x
        shouldUpdateTimeWithScroll = true
        // 这里根据偏移来计算当前时间
        let deltaX = scrollOffset - frame.width / 2 + linePositionX
        shouldUpdateSeekTime = false
        currentTime = Double(deltaX / viewTotalWidth) * totalDuration
        let seekTime = currentTime
        // 根据偏移量计算出seekTime
        checkAddingView(seekTime)
        // 这里重新更新时间
        currentTime = seekTime
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        checkCurrentTime(scrollView)
        
        self.delegate?.timelineViewDidEndDragging(self)
    }
    
    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    //滚动结束的延迟性高
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        checkCurrentTime(scrollView)
        
        if currentStatus == .adding {
            autoReachEnd = true
            dragScroll = false
        }
        
        self.delegate?.timelineViewDidEndDecelerating(self)
    }
    
    //MARK: - private override
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame);
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    deinit {
        DLog("LYTimelineView deinit")
    }
    
}

extension LYTimelineView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.requestFrames == nil {
            return 0
        }
        
        return requestFrames.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "frameCell", for: indexPath) as! FrameCell
        
        let item = requestFrames[indexPath.row]

        if self.placeholderCGImage != nil {
            cell.imageView.image = UIImage(cgImage: self.placeholderCGImage)
        }
        
        display(imageView: cell.imageView, item: item)
        
        return cell
    }
    
    fileprivate func display(imageView: UIImageView, item: FrameItem) {
        
        if let displayer = self.displayer {
            // 显示图片
            displayer.displayImage(imageView, self.asset, item.localIdentifier, item.mediaType, item.requestedTime, self.flowLayout().itemSize, self.imageGenerator)
            return
        }
        
        dispatchQueue.async(execute: { [weak self] in
            
            if self == nil {
                return
            }
            
            var image: UIImage!
            if self!.timeline != nil {
                let videoItem = self!.timeline.requestItem(CMTime: item.requestedTime)
                if videoItem.mediaType == .image {
                    let phAsset = PHAsset.fetchAsset(localIdentifier: videoItem.localIdentifier)
                    image = phAsset?.image(targetSize: self!.flowLayout().itemSize)
                } else {
                    var actualTime = CMTime.zero
                    do {
                        
                        var copyTime = item.requestedTime
                        if copyTime == nil || copyTime == CMTime.zero {
                            copyTime = copyFirstTime
                        }
                        
                        let cgImage = try self?.imageGenerator.copyCGImage(at: copyTime!, actualTime: &actualTime)
                        if cgImage != nil {
                            image = UIImage(cgImage: cgImage!)
                        }
                    } catch let error as NSError {
                        DLog("error: \(error.description)")
                    }
                }
            } else {
                var actualTime = CMTime.zero
                do {
                    
                    var copyTime = item.requestedTime
                    if copyTime == nil || copyTime == CMTime.zero {
                        copyTime = copyFirstTime
                    }
                    let cgImage = try self?.imageGenerator.copyCGImage(at: copyTime!, actualTime: &actualTime)
                    if cgImage != nil {
                        image = UIImage(cgImage: cgImage!)
                    }
                } catch let error as NSError {
                    DLog("error: \(error.description)")
                }
            }
            
            DispatchQueue.main.async(execute: {
                
                if image != nil {
                    imageView.image = image
                }
                
                imageView.alpha = 0.5
                UIView.animate(withDuration: 0.3, animations: {
                    imageView.alpha = 1
                })
            })
            
            })
    }
    
}

extension LYTimelineView: LYSliderViewDelegate {
    
    /// delta拖动左边滑块的偏移量 sliderFrame为此时在滑动视图内的frame
    internal func sliderView(_ sliderView: LYSliderView, didSlideLeftSliderFrame sliderFrame: CGRect, withDelta dX: CGFloat) {
        // 用户拖动左滑块, 在防止滑块超出collectionView范围的前提下更新SliderView的frame
        var delta = dX
        let minDelta = collectionView.frame.minX - self.convert(sliderView.frame, from: collectionView).minX
        if delta < minDelta {
            delta = minDelta
        }
        
        // 修改编辑块的
        sliderView.frame = moveLeftEdgeOfRect(sliderView.frame, dx: delta, isSlider: true)
        
        // 更新selection范围
        if let editingSelection = editingSelection, let view = selectionViews[editingSelection] {
            let updatedFrame = moveLeftEdgeOfRect(view.frame, dx: delta, isSlider: false)
            view.frame = updatedFrame
            
            let deltaTime = timeOfPositionXInCollectionOfTime(updatedFrame.minX) - editingSelection.startTime
            editingSelection.startTime = editingSelection.startTime + deltaTime
            if trimStartEnabled {
                editingSelection.duration = editingSelection.duration - deltaTime
            }
            
            self.delegate?.timelineView(self, didChangeSelection: editingSelection)
        }
        
        // 更新linePositionX为左滑块的右边缘
        linePositionX = self.convert(sliderFrame, from: sliderView).maxX
    }
    
    /// delta拖动右边边滑块的偏移量 sliderFrame为此时在滑动视图内的frame
    internal func sliderView(_ sliderView: LYSliderView, didSlideRightSliderFrame sliderFrame: CGRect, withDelta dX: CGFloat) {
        
        // 用户拖动右滑块, 在纺织滑块超出collectionView范围的前提下更新sliderView的frame
        var delta = dX
        let maxDelta = collectionView.frame.maxX - self.convert(sliderView.frame, from: collectionView).maxX
        
        if delta > maxDelta {
            delta = maxDelta
        }
        
        sliderView.frame = moveRightEdgeOfRect(sliderView.frame, dx: delta)
        
        // 更新selection的范围
        if let editingSelection = editingSelection, let view = selectionViews[editingSelection] {
            let updateFrame = moveRightEdgeOfRect(view.frame, dx: delta)
            view.frame = updateFrame
            editingSelection.duration = timeOfPositionXInCollectionOfTime(updateFrame.maxX) - editingSelection.startTime
            
            self.delegate?.timelineView(self, didChangeSelection: editingSelection)
        }
        
        linePositionX = self.convert(sliderFrame, from: sliderView).minX + delta
    }
    
    /// 滑动结束
    internal func sliderViewDidFinishSliding(_ sliderView: LYSliderView) {
        // 拖动结束, 滚动collection使白线居于中间
        
        UIView.animate(withDuration: 0.05, animations: { [weak self] () -> Void in
            self?.shouldUpdateTimeWithScroll = false;
            self?.collectionView.contentOffset.x += (self!.linePositionX - self!.center.x)
            self?.shouldUpdateTimeWithScroll = true
            
            self?.linePositionX = self!.center.x
        }) 
        
    }
    
    enum LYTimelineViewStatus {
        case normal, adding, editing
    }
    
    class FrameCell: UICollectionViewCell {
        
        var imageView: UIImageView!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            setup()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            
            setup()
        }
        
        fileprivate func setup() {
            self.clipsToBounds = true
            imageView = UIImageView(frame: self.bounds)
            imageView.contentMode = UIView.ContentMode.scaleAspectFill
            imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            
            addSubview(imageView)
        }
        
    }
    
}

// layout用于解决collectionView的内容大小及不完全显示的cell
class LYTimelineViewFlowLayout: UICollectionViewFlowLayout {
    
    /// 最后一个cel是否显示完全 default 与父类相同操作
    var lastIntegral: Bool = true
    
    /// 最后一个cell相对item cell的宽度比例 lastIntegral = true 时,忽略这个属性
    var lastWidthRatio:CGFloat = 0
    
    /// 最后一个cell的属性
    var lastAttributes:UICollectionViewLayoutAttributes?
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView , collectionView.numberOfSections > 0 && collectionView.numberOfItems(inSection: 0) > 0 else {
            
            return
        }
        
        //
        if lastIntegral == false {// 最后一个cell需要不完全显示时计算出frame
            // 计算最后一个cell的frame
            let itemCount = collectionView.numberOfItems(inSection: 0)
            
            let indexPath = IndexPath(row: itemCount - 1, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            let currentX = (itemSize.width + minimumInteritemSpacing) * (CGFloat(itemCount) - 1) + collectionView.bounds.width / 2
            
            let currentY = collectionView.bounds.height - itemSize.height - sectionInset.top - sectionInset.bottom
            
            attributes.frame = CGRect(x: currentX, y: currentY, width: itemSize.width * lastWidthRatio, height: itemSize.height)
            
            lastAttributes = attributes
        }
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if lastIntegral {
            return super.layoutAttributesForElements(in: rect)
        }
        
        if let layoutAttrs = super.layoutAttributesForElements(in: rect) {
            
            for attr in layoutAttrs {
                if lastIntegral == false && (attr.indexPath as NSIndexPath).row == (lastAttributes!.indexPath as NSIndexPath).row {
                    attr.frame = lastAttributes!.frame
                } else {
                    attr.frame = CGRect(x: attr.frame.origin.x, y: attr.frame.origin.y, width: itemSize.width, height: itemSize.height)
                }
            }
            return layoutAttrs
        }
        
        return nil
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        guard let collectionView = collectionView else {
            
            return super.layoutAttributesForItem(at: indexPath)
        }
        
        let count = collectionView.numberOfItems(inSection: 0)
        
        // 如果是最后一个片段
        if lastIntegral == false && indexPath.row == (count - 1) {
            return lastAttributes
        }
        
        return super.layoutAttributesForItem(at: indexPath)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        
        return false
    }
    
    // 返回内容视图的总大小
    override var collectionViewContentSize : CGSize {
        var size = super.collectionViewContentSize
        if lastIntegral == false {// 需要减去裁掉的区域
            
            let delta = itemSize.width - itemSize.width * lastWidthRatio
            size.width -= delta
        }
        
        return size
    }
    
}

open class LYTimelineSelection: NSObject {
    open var startTime: TimeInterval
    open var duration: TimeInterval
    
    open var endTime: TimeInterval {
        get {
            return startTime + duration;
        }
    }
    
    fileprivate override init() {
        self.startTime = 0
        self.duration = 0
        super.init()
    }
    
    public init(startTime: TimeInterval, duration: TimeInterval) {
        self.startTime = startTime
        self.duration = duration
        super.init();
    }
    
    // 判断是否包含该时间
    open func containTime(_ time: TimeInterval) ->Bool {
        return time >= startTime && time <= endTime;
    }
    
}

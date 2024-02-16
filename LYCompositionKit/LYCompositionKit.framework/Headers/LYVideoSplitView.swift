//
//  LYVideoSplitView.swift
//  LYCompositionKit
//
//  Created by tony on 2017/12/21.
//  Copyright © 2017年 chengkai. All rights reserved.
//

import UIKit
import AVFoundation

// 请求的图片帧
private class FrameItem {
    
    /** 提取的时间 */
    fileprivate var requestedTime: CMTime!
    
    /** 提取的图片 */
    fileprivate var image: CGImage!
    
}

private let cellIdentifier = "Cell";
/// 视频拆分组件
open class LYVideoSplitView: UIView {
    
    open weak var delegate: LYVideoSplitViewDelegate?;
    
    let halfSliderWidth:CGFloat = 10;
    // 根据时长判断最小间距
    fileprivate var minimumPt:CGFloat = 0;
    
    // 资源的原始时长, 用于处理图片合成编辑的情况, 图片的情况必须必须赋值, 否则显示不准确
    open var assetDuration: CMTime!
    
    // 最小保留的时长
    open var minimumTime:CMTime = CMTimeMake(value: 1, timescale: 2) {
        didSet {
            
        }
    }
    
    /// 播放进度 0.0 ~ 1.0
    open var progress: CGFloat = 0 {
        didSet {
            
            // 总宽度
            let width = self.frame.width - halfSliderWidth * 2
            
            let originX = width * progress + halfSliderWidth
            var progressViewFrame = self.progressView.frame
            progressViewFrame.origin.x = originX
            self.progressView.frame = progressViewFrame
        }
    }
    
    // 显示播放进度视图
    fileprivate var progressView: UIImageView!
    fileprivate let progressViewWidth: CGFloat = 2
    // 设置进度显示的颜色
    open var progressTintColor: UIColor = UIColor.white {
        didSet {
            progressView.backgroundColor = progressTintColor
        }
    }
    
    fileprivate var contentView:UICollectionView!;// 用于加载帧的内容视图
    fileprivate var contentLayout:UICollectionViewFlowLayout!;

    // 用于内边距
    open var edgeInset:UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            
        }
    }
    
    fileprivate var cellSize:CGFloat!;// 单元格的宽高
    
    // 提取第一张之后作为站位图片
    fileprivate var placeholderCGImage: CGImage!
    fileprivate var requestFrames: [FrameItem]!
    
    // 编辑的是图片
    open var cuttingImage: UIImage!
    
    /// 视频对象,同时用于处理合成对象
    open var asset:AVAsset! {// 设置之前已经加载了媒体信息
        didSet {
            if self.asset == nil {
                return
            }
            
            self.imageGenerator = self.createImageGenerator(asset)
            self.prepareData()
        }
    }
    
    fileprivate var imageGenerator:AVAssetImageGenerator!
    // 创建一个串行队列, 用于顺序加载图片
    fileprivate var dispatchQueue: DispatchQueue!
    
    public override init(frame: CGRect) {
        super.init(frame: frame);
        self.setup(frame);
    }
    
    public init(frame: CGRect, asset:AVAsset) {
        super.init(frame: frame);
        
        self.asset = asset
        self.setup(frame);
    }
    
    required public init?(coder aDecoder: NSCoder) {//
        super.init(coder: aDecoder);
        self.setup(frame);
    }
    
    func setup(_ frame: CGRect) {
        
        self.backgroundColor = UIColor.clear;
        self.clipsToBounds = true;
        
        self.dispatchQueue = DispatchQueue(label: "DISPATCH_QUEUE_SERIAL.videoRangeSlider", attributes: [])
        
        self.contentLayout = UICollectionViewFlowLayout();
        self.contentLayout.minimumInteritemSpacing = 0.0;
        self.contentLayout.minimumLineSpacing = 0.0;
        self.contentLayout.scrollDirection = .horizontal;
        
        let height = frame.size.height - self.edgeInset.top - self.edgeInset.bottom;
        self.contentLayout.itemSize = CGSize(width: height, height: height);
        
        let contentFrame = CGRect(x: self.edgeInset.left + halfSliderWidth, y: self.edgeInset.top, width: self.frame.width - self.edgeInset.left - self.edgeInset.right - halfSliderWidth * 2, height: self.frame.height - self.edgeInset.top - self.edgeInset.bottom);
        self.contentView = UICollectionView(frame: contentFrame, collectionViewLayout: self.contentLayout);
        
        self.contentView.backgroundColor = UIColor.clear;
        self.contentView.showsHorizontalScrollIndicator = false;
        self.contentView.alwaysBounceHorizontal = false;
        self.contentView.alwaysBounceVertical = false;
        self.contentView.isUserInteractionEnabled = false;
        self.contentView.dataSource = self;
        self.contentView.register(ThumbnailCell.self, forCellWithReuseIdentifier: cellIdentifier);
        
        self.addSubview(self.contentView);
        
        self.progressView = UIImageView(frame: CGRect(x: halfSliderWidth, y: self.edgeInset.top, width: progressViewWidth, height: contentView.frame.size.height))
        self.progressView.backgroundColor = progressTintColor
        self.progressView.layer.cornerRadius = 2
        self.addSubview(progressView)
        
        if self.asset != nil {
            self.imageGenerator = self.createImageGenerator(asset)
        }
    }
    
    /**
     * 创建图片生成器
     */
    fileprivate func createImageGenerator(_ asset: AVAsset) ->AVAssetImageGenerator {
        let imageGenerator = AVAssetImageGenerator(asset: asset);
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceBefore = CMTimeMake(value: 1, timescale: 600)
        imageGenerator.requestedTimeToleranceAfter = CMTimeMake(value: 1, timescale: 600)
        // 自动配置宽高比
        imageGenerator.maximumSize = CGSize(width: self.frame.height * UIScreen.main.scale, height: 0)
        
        return imageGenerator
    }
    
    /** 准备显示数据 */
    fileprivate func prepareData() {
        
        if self.asset == nil {
            return
        }
        
        let minimumSecond = CGFloat(CMTimeGetSeconds(minimumTime));
        
        self.minimumPt = (self.frame.width - self.edgeInset.left - self.edgeInset.right - halfSliderWidth * 2) / CGFloat(CMTimeGetSeconds(self.asset.duration)) * minimumSecond;
        
        self.requestFrames = self.generatorFrameItems()
        
        var actualTime = CMTime.zero
        do {
            self.placeholderCGImage = try self.imageGenerator.copyCGImage(at: copyFirstTime, actualTime: &actualTime)
        } catch let error as NSError {
            DLog("error: \(error.description)")
        }
        
        self.contentView.reloadData()
    }
    
    // 递归提取站位图片
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
    
    fileprivate func setupLayout() {
        let height = frame.size.height - self.edgeInset.top - self.edgeInset.bottom;
        self.contentLayout.itemSize = CGSize(width: height, height: height);
        
        let contentFrame = CGRect(x: self.edgeInset.left + halfSliderWidth * 2, y: self.edgeInset.top, width: contentSize(), height: self.frame.height - self.edgeInset.top - self.edgeInset.bottom);
        self.contentView.frame = contentFrame;
        
        self.progressView.frame = CGRect(x: contentView.frame.origin.x, y: contentView.frame.origin.y, width: progressViewWidth, height: contentView.frame.size.height)
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    /// 通知重绘
    open func invalidate() {
        self.setupLayout();
        self.prepareData()
    }
    
    fileprivate func contentSize() ->CGFloat {
        
        return self.frame.width - self.edgeInset.left - self.edgeInset.right - halfSliderWidth * 2 * 2
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.delegate?.videoSplitViewTouchBegan(self)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        
        if location.x < halfSliderWidth {
            self.progress = 0.0
        } else if location.x > self.frame.width - halfSliderWidth {
            self.progress = 1.0
        } else {
            self.progress = (location.x - halfSliderWidth) / (self.frame.width - halfSliderWidth * 2)
        }
        
        self.delegate?.videoSplitView(self, progress: self.progress)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate?.videoSplitViewTouchEnd(self)
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate?.videoSplitViewTouchEnd(self)
    }
    
    /** 生成需要提取的时间 */
    fileprivate func generatorFrameItems() ->[FrameItem] {
        
        var frameItems = [FrameItem]();
        
        // 计算出需要多少时间
        let width = self.frame.width - self.edgeInset.left * 2 - halfSliderWidth * 2
        let count = width / (self.frame.height - self.edgeInset.top - self.edgeInset.bottom);
        
        var durationTime: CMTime! = self.assetDuration
        if durationTime == nil {
            durationTime = self.asset.duration
        }
        
        let unitValue = durationTime.value / Int64(count);
        let unitTime = CMTimeMake(value: Int64(unitValue), timescale: durationTime.timescale);
        
        for i:Int64 in 0...Int64(count) {
            
            let tmpTime = CMTimeMake(value: unitTime.value * i, timescale: unitTime.timescale);
            
            let frameItem = FrameItem()
            frameItem.requestedTime = tmpTime
            
            frameItems.append(frameItem)
        }
        
        return frameItems
    }
    
}

extension LYVideoSplitView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.requestFrames == nil {
            return 0;
        }
        
        return self.requestFrames.count;
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ThumbnailCell;
        
        let item = self.requestFrames[indexPath.row]
        
        if item.image != nil {
            cell.imageView.image = UIImage(cgImage: item.image)
        } else {
            
            if self.cuttingImage != nil {
                cell.imageView.image = cuttingImage
            } else {
                if self.placeholderCGImage != nil {
                    cell.imageView.image = UIImage(cgImage: self.placeholderCGImage)
                }
                
                dispatchQueue.async(execute: { [weak self] in
                    
                    var actualTime = CMTime.zero
                    do {
                        var copyTime = item.requestedTime
                        if copyTime == nil || copyTime == CMTime.zero {
                            copyTime = copyFirstTime
                        }
                        item.image = try self?.imageGenerator.copyCGImage(at: copyTime!, actualTime: &actualTime)
                    } catch let error as NSError {
                        DLog("error: \(error.description)")
                    }
                    
                    DispatchQueue.main.async(execute: {
                        
                        if item.image != nil {
                            cell.imageView.image = UIImage(cgImage: item.image)
                        }
                        
                        cell.imageView.alpha = 0.5
                        UIView.animate(withDuration: 0.3, animations: {
                            cell.imageView.alpha = 1
                        })
                    })
                    
                })
            }
        }
        
        return cell;
    }
    
}

fileprivate class ThumbnailCell:UICollectionViewCell {
    
    var imageView:UIImageView;
    
    override init(frame: CGRect) {
        self.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height));
        self.imageView.contentMode = .scaleAspectFill;
        
        super.init(frame: frame);
        
        self.addSubview(self.imageView);
        self.clipsToBounds = true;
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.imageView = UIImageView(frame: CGRect.zero);
        self.imageView.contentMode = .scaleAspectFill;
        
        super.init(coder: aDecoder);
        
        self.addSubview(self.imageView);
        self.clipsToBounds = true;
    }
    
    override func awakeFromNib() {
        super.awakeFromNib();
    }
    
}

public protocol LYVideoSplitViewDelegate: NSObjectProtocol {
    
    // 加载完成
    func videoSplitViewDidLoad(_ videoSplitView: LYVideoSplitView)
    
    // 滑动到某个进度
    func videoSplitView(_ videoSplitView: LYVideoSplitView, progress: CGFloat)
    
    /// 滑动开始
    func videoSplitViewTouchBegan(_ videoSplitView: LYVideoSplitView)
    
    /// 滑动结束
    func videoSplitViewTouchEnd(_ videoSplitView: LYVideoSplitView)
    
}


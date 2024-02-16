//
//  LYVideoRangeSlider.swift
//  LYVideoRangeSlider
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkaizone. All rights reserved.
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
/// 视频剪切组件
open class LYVideoRangeSlider: UIView {
    
    open weak var delegate:LYVideoRangeSliderDelegate?;
    
    let halfSliderWidth:CGFloat = 10;
    // 根据时长判断最小间距
    fileprivate var minimumPt:CGFloat = 0;
    
    // 资源的原始时长, 用于处理图片合成编辑的情况, 图片的情况必须必须赋值, 否则显示不准确
    open var assetDuration: CMTime!
    
    /// 播放进度 0.0 ~ 1.0
    open var progress: CGFloat = 0 {
        didSet {
            
            if progress == 0 || progress == 1 {
                self.progressView.isHidden = true
            } else {
                self.progressView.isHidden = false
            }
            
            // 总宽度
            let width = self.rightSlider.frame.origin.x - self.leftSlider.frame.origin.x - self.leftSlider.frame.width
            
            let originX = width * progress + self.leftSlider.frame.origin.x + self.leftSlider.frame.width
            var progressViewFrame = self.progressView.frame
            progressViewFrame.origin.x = originX
            self.progressView.frame = progressViewFrame
        }
    }
    
    // 可以使用自定义的图片,内容图片始终在滑块的内部
    fileprivate var leftSlider:UIButton!;
    fileprivate var rightSlider:UIButton!;
    
    // -1: 未选中滑块 0: left 1: right
    open var selectedStatus: Int {
        
        if leftSlider.isSelected {
            return 0
        }
        
        if rightSlider.isSelected {
            return 1
        }
        
        return -1
    }
    
    // 显示播放进度视图
    fileprivate var progressView: UIView!
    fileprivate let progressViewWidth: CGFloat = 2
    // 设置进度显示的颜色
    open var progressTintColor: UIColor = UIColor.white {
        didSet {
            progressView.backgroundColor = progressTintColor
        }
    }
    
    fileprivate var leftCover:UIView!;// 半透明遮罩
    fileprivate var rightCover:UIView!;
    
    fileprivate var contentView:UICollectionView!;// 用于加载帧的内容视图
    fileprivate var contentLayout:UICollectionViewFlowLayout!;
    
    fileprivate var shouldUpdateLeft: Bool = true
    open var leftThumbRatio:CGFloat = 0 {
        didSet {
            if shouldUpdateLeft == false {
                shouldUpdateLeft = true
                return
            }
            
            if leftThumbRatio < 0 {
                shouldUpdateLeft = true
                leftThumbRatio = 0
                return
            }
            if leftThumbRatio > 1 {
                shouldUpdateLeft = true
                leftThumbRatio = 1
                return
            }
            
            var temp = self.leftSlider.frame;
            
            temp.origin.x = leftThumbRatio * (self.frame.width - halfSliderWidth * 2)
            self.leftSlider.frame = temp;
            
            var tempCoverFrame = self.leftCover.frame;
            tempCoverFrame.size.width = temp.origin.x
            self.leftCover.frame = tempCoverFrame;
            
            shouldUpdateLeft = true
            
            self.progress = 0;
        }
    }
    
    fileprivate var shouldUpdateRight: Bool = true
    open var rightThumbRatio:CGFloat = 1 {
        didSet {
            if shouldUpdateRight == false {
                shouldUpdateRight = true
                return
            }
            
            if rightThumbRatio < 0 {
                shouldUpdateRight = true
                rightThumbRatio = 0
                return
            }
            if rightThumbRatio > 1 {
                shouldUpdateRight = true
                rightThumbRatio = 1
                return
            }
            
            var temp = self.rightSlider.frame
            let originX = rightThumbRatio * (self.frame.width - halfSliderWidth * 4) + halfSliderWidth * 2
            temp.origin.x = originX
            self.rightSlider.frame = temp;
            
            var tempCoverFrame = self.rightCover.frame;
            tempCoverFrame.origin.x = originX
            
            let coverWidth = self.frame.width - self.halfSliderWidth * 2 - originX;
            tempCoverFrame.size.width = coverWidth < 0 ? 0 : coverWidth;
            self.rightCover.frame = tempCoverFrame;
            self.progress = 1;
        }
    }
    
    // 最小保留的时长
    open var minimumTime:CMTime = CMTimeMake(value: 1, timescale: 2) {
        didSet {
            
        }
    }
    
    open var minimumRatio: CGFloat {
        
        get {
            if(asset == nil) {
                return 1
            }
            
            // 允许的最小的滑动比例
            let minimumRatio = CMTimeGetSeconds(minimumTime) / CMTimeGetSeconds(asset.duration)
            
            return CGFloat(minimumRatio)
        }
    }
    
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
        
        self.progressView = UIView(frame: CGRect(x: halfSliderWidth, y: self.edgeInset.top, width: progressViewWidth, height: contentView.frame.size.height))
        self.progressView.backgroundColor = progressTintColor
        self.progressView.layer.cornerRadius = 2
        self.addSubview(progressView)
        
        self.leftCover = UIView();
        self.leftCover.frame = CGRect(x: self.halfSliderWidth, y: self.edgeInset.top, width: 0, height: self.frame.height - self.edgeInset.top - self.edgeInset.bottom);
        self.leftCover.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6);
        
        self.addSubview(self.leftCover);
        
        self.rightCover = UIView();
        self.rightCover.frame = CGRect(x: self.halfSliderWidth * 2 + contentSize(), y: self.edgeInset.top, width: 0, height: self.frame.height - self.edgeInset.top - self.edgeInset.bottom);
        self.rightCover.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6);
        
        self.addSubview(self.rightCover);
        
        self.leftSlider = UIButton(type: .custom);
        self.leftSlider.frame = CGRect(x: 0, y: 0, width: halfSliderWidth * 2, height: frame.size.height);
        self.leftSlider.isUserInteractionEnabled = true;
        self.leftSlider.clipsToBounds = true;
        self.leftSlider.backgroundColor = UIColor.yellow;
        self.addSubview(self.leftSlider);
        
        let leftGesture = UIPanGestureRecognizer(target: self, action: #selector(handleGestureLeft(_:)));
        self.leftSlider.addGestureRecognizer(leftGesture);
        
        self.rightSlider = UIButton(type: .custom);
        self.rightSlider.frame = CGRect(x: frame.size.width - halfSliderWidth * 2, y: 0, width: halfSliderWidth * 2, height: frame.size.height);
        self.rightSlider.isUserInteractionEnabled = true;
        self.rightSlider.clipsToBounds = true;
        self.rightSlider.backgroundColor = UIColor.yellow;
        self.addSubview(self.rightSlider);
        
        let rightGesture = UIPanGestureRecognizer(target: self, action: #selector(handleGestureRight(_:)));
        self.rightSlider.addGestureRecognizer(rightGesture);
        
//        let viewGesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
//        self.addGestureRecognizer(viewGesture)
        
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
        
        self.leftCover.frame = CGRect(x: self.halfSliderWidth * 2, y: self.edgeInset.top, width: 0, height: self.frame.height - self.edgeInset.top - self.edgeInset.bottom);
        
        self.rightCover.frame = CGRect(x: self.halfSliderWidth * 2 + contentSize(), y: self.edgeInset.top, width: 0, height: self.frame.height - self.edgeInset.top - self.edgeInset.bottom);
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    /// 通知重绘
    open func invalidate() {
        self.setupLayout();
        self.prepareData()
    }
    
    open func setThumbImage(_ normalName:String, highlightedName:String) {
        
        let trimImage = UIImage(named: normalName);
        let trimImageSelect = UIImage(named: highlightedName);
        self.leftSlider.setImage(trimImage, for: UIControl.State());
        self.leftSlider.setImage(trimImageSelect, for: .highlighted);
        self.leftSlider.setImage(trimImageSelect, for: .selected);
        self.rightSlider.setImage(trimImage, for: UIControl.State());
        self.rightSlider.setImage(trimImageSelect, for: .highlighted);
        self.rightSlider.setImage(trimImageSelect, for: .selected);
        
        self.leftSlider.backgroundColor = UIColor.clear;
        self.rightSlider.backgroundColor = UIColor.clear;
    }
    
    open func setThumbImage(thumb: Int, _ normalName:String, _ highlightedName:String) {
        
        let trimImage = UIImage(named: normalName);
        let trimImageSelect = UIImage(named: highlightedName);
        
        if thumb == 0 {// 左边
            self.leftSlider.setImage(trimImage, for: UIControl.State());
            self.leftSlider.setImage(trimImageSelect, for: .highlighted);
            self.leftSlider.setImage(trimImageSelect, for: .selected);
            self.leftSlider.backgroundColor = UIColor.clear;
        } else if thumb == 1 {// 右边
            self.rightSlider.setImage(trimImage, for: UIControl.State());
            self.rightSlider.setImage(trimImageSelect, for: .highlighted);
            self.rightSlider.setImage(trimImageSelect, for: .selected);
            self.rightSlider.backgroundColor = UIColor.clear;
        }
    }
    
    fileprivate func contentSize() ->CGFloat {
        
        return self.frame.width - self.edgeInset.left - self.edgeInset.right - halfSliderWidth * 2 * 2
    }
    
    @objc func handleGestureLeft(_ gesture:UIPanGestureRecognizer) {
        
        self.leftSlider.isSelected = true;
        self.rightSlider.isSelected = false;
        self.bringSubviewToFront(self.leftSlider);
        
        let translation:CGPoint = gesture.translation(in: self);
        switch gesture.state {
        case .began:
            self.delegate?.videoRangeSliderTouchBegan(self)
            break
        case .changed:
            var temp = self.leftSlider.frame;
            
            var originX = temp.origin.x + translation.x;
            
            if originX < 0 {
                originX = 0;
            } else if originX + temp.width + self.minimumPt > self.rightSlider.frame.origin.x {
                originX = self.rightSlider.frame.origin.x - temp.width - self.minimumPt;
            }
            
            temp.origin.x = originX;
            self.leftSlider.frame = temp;
            
            var progressViewFrame = self.progressView.frame
            progressViewFrame.origin.x = originX + self.leftSlider.frame.width
            self.progressView.frame = progressViewFrame
            
            var tempCoverFrame = self.leftCover.frame;
            tempCoverFrame.size.width = originX;
            self.leftCover.frame = tempCoverFrame;
            
            shouldUpdateLeft = false
            self.leftThumbRatio = originX / contentSize();
            
            self.progress = 0
            
            gesture.setTranslation(CGPoint.zero, in: self);
            
            self.delegate?.videoRangeSlider(self, leftRatio: self.leftThumbRatio, rightRatio: self.rightThumbRatio, state: 0);
            
            break;
        case .cancelled, .ended, .failed:
            self.delegate?.videoRangeSliderTouchEnd(self)
            break;
        default:
            break;
        }
        
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.rightSlider.isSelected = false
        self.leftSlider.isSelected = false
        self.delegate?.videoRangeSliderTouchBegan(self)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        
        if location.x < self.leftSlider.frame.origin.x + self.leftSlider.frame.width {
    
            self.progress = 0.0
        } else if location.x > self.rightSlider.frame.origin.x {

            self.progress = 1.0
        } else {
            // 总宽度
            let width = self.rightSlider.frame.origin.x - self.leftSlider.frame.origin.x - self.leftSlider.frame.width
        
            self.progress = (location.x - self.leftSlider.frame.origin.x - self.leftSlider.frame.width) / width
        }
        
        self.delegate?.videoRangeSlider(self, progress: self.progress)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate?.videoRangeSliderTouchEnd(self)
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate?.videoRangeSliderTouchEnd(self)
    }
    
    @objc func handleGestureRight(_ gesture:UIPanGestureRecognizer) {
        
        self.rightSlider.isSelected = true;
        self.leftSlider.isSelected = false;
        self.bringSubviewToFront(self.rightSlider);
        
        let translation:CGPoint = gesture.translation(in: self);
        switch gesture.state {
        case .began:
            self.delegate?.videoRangeSliderTouchBegan(self)
            break
        case .changed:
            var temp = self.rightSlider.frame;
            
            var originX = temp.origin.x + translation.x;
            
            if originX > self.frame.width - halfSliderWidth * 2 {
                originX = self.frame.width - halfSliderWidth * 2 ;
            } else if originX < self.leftSlider.frame.origin.x + self.leftSlider.frame.width + self.minimumPt {
                originX = self.leftSlider.frame.origin.x + self.leftSlider.frame.width + self.minimumPt;
            }
            
            temp.origin.x = originX;
            self.rightSlider.frame = temp;
            
            var tempCoverFrame = self.rightCover.frame;
            tempCoverFrame.origin.x = originX;
            
            let coverWidth = self.frame.width - self.halfSliderWidth * 2 - originX;
            tempCoverFrame.size.width = coverWidth < 0 ? 0 : coverWidth;
            self.rightCover.frame = tempCoverFrame;
            
            shouldUpdateRight = false
            self.rightThumbRatio = 1 - coverWidth / contentSize();
            
            self.progress = 1.0
            
            gesture.setTranslation(CGPoint.zero, in: self);
            
            self.delegate?.videoRangeSlider(self, leftRatio: self.leftThumbRatio, rightRatio: self.rightThumbRatio, state: 1);
            
            break;
        case .cancelled, .ended, .failed:
            self.delegate?.videoRangeSliderTouchEnd(self)
            break;
        default:
            break;
        }
        
    }
    
    /** 生成需要提取的时间 */
    fileprivate func generatorFrameItems() ->[FrameItem] {
        
        var frameItems = [FrameItem]();
        
        // 计算出需要多少时间
        let width = self.frame.width - self.edgeInset.left * 2;
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

extension LYVideoRangeSlider:UICollectionViewDataSource {
    
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

public protocol LYVideoRangeSliderDelegate:NSObjectProtocol {
    
    // 加载完成
    func videoRangeSliderDidLoad(_ slider:LYVideoRangeSlider)
    
    /// 滑块滑动事件 0:左边滑块事件 1:右边滑块事件
    func videoRangeSlider(_ slider:LYVideoRangeSlider, leftRatio:CGFloat, rightRatio:CGFloat, state:Int);
    
    // 滑动到某个进度
    func videoRangeSlider(_ slider: LYVideoRangeSlider, progress: CGFloat)
    
    /// 滑动开始
    func videoRangeSliderTouchBegan(_ slider: LYVideoRangeSlider)
    
    /// 滑动结束
    func videoRangeSliderTouchEnd(_ slider: LYVideoRangeSlider)
    
}

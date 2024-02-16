//
//  LYEmoticonKeyboard.swift
//  LYEmoticonKeyboard
//
//  Created by tony on 16/2/24.
//  Copyright © 2016年 tony. All rights reserved.
//

import UIKit

public protocol LYEmoticonKeyboardDelegate: NSObjectProtocol {
    
    /// 表情面板出现
    func emoticonKeyboardDidAppear(_ emoticonKeyboard: LYEmoticonKeyboard)
    
    /// 表情面板隐藏
    func emoticonKeyboardDidDisappear(_ emoticonKeyboard: LYEmoticonKeyboard)
    
    /// 返回选中的表情
    func emoticonKeyboard(_ emoticonKayboard: LYEmoticonKeyboard, didSelectItem emoticon: LYEmoticon)
    
}

let keyboardHeight: CGFloat = 250
/// 表情贴图键盘
open class LYEmoticonKeyboard: UIView {

    /**
     * 获取实例
     */
    public class func shared() ->LYEmoticonKeyboard {
        struct Static {
            static var instance: LYEmoticonKeyboard = LYEmoticonKeyboard(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: keyboardHeight))
        }
        return Static.instance;
    }
    

    open weak var keyboardDelegate: LYEmoticonKeyboardDelegate?
    
    /// 表情显示的行数和列数
    open var row: Int = 3
    open var column: Int = 6
    
    /// 显示方式 0:显示文字   1:显示图片
    open var type: Int = 0
    
    fileprivate var reuseIdentifier: String = "emoticonCell"
    fileprivate var collectionView: UICollectionView!
    
    // 工具条
    fileprivate var toolbar: LYEmoticonToolbar!
    
    fileprivate var pageControl: UIPageControl!
    
    /// 表情数据源 --- 含内置和下载的
    open var emoticonPackages: [LYEmoticonPackage]! {
        didSet {
            guard let packages = emoticonPackages else {
                return
            }
            
            toolbar.dataSource = packages
            
            for package in packages {
                package.loadEmoticonGroups(row, column: column)
            }
            
            if packages.count > 0 {
                let package = emoticonPackages[0]
                pageControl.numberOfPages = package.emoticonGroups.count
            }
            
        }
    }
    
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        pageControl = UIPageControl(frame: CGRect.zero)
        
        toolbar = LYEmoticonToolbar(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 40))
        
        collectionView.backgroundColor = UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
        collectionView.clipsToBounds = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.register(LYEmoticonCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        self.addSubview(collectionView)
        
        pageControl.numberOfPages = 1
        pageControl.pageIndicatorTintColor = UIColor(red: 222/255.0, green: 222/255.0, blue: 222/255.0, alpha: 1)
        pageControl.currentPageIndicatorTintColor = UIColor(red: 253/255.0, green: 129/255.0, blue: 36/255.0, alpha: 1)
        // pageControl.hidden = true
        self.addSubview(pageControl)
        
        // 添加工具条
        toolbar.emoticonToolbarDelegate = self
        self.addSubview(toolbar)
        
        addConstraintForSubviews()
    }

    /// 只允许用代码添加
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 添加视图约束
    func addConstraintForSubviews() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        // 顶部左右全填充
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: [.alignAllTop], metrics: nil, views: ["collectionView" : collectionView]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[pageControl]-0-|", options: [.alignAllTop], metrics: nil, views: ["pageControl":pageControl]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[toolbar]-0-|", options: [.alignAllTop], metrics: nil, views: ["toolbar" : toolbar]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[collectionView]-0-[toolbar(40)]-0-|", options: [.alignAllLeft, .alignAllRight], metrics: nil, views: ["collectionView": collectionView, "toolbar": toolbar]))
        
        self.addConstraint(NSLayoutConstraint(item: pageControl, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: toolbar, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: -5))
        
        pageControl.addConstraint(NSLayoutConstraint(item: pageControl, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 20))
        
    }
    
    /// 第一个表情
    public func firstEmoticon() ->LYEmoticon? {
        
        return loadEmotion(0)
    }
    
    func loadEmotion(_ packageIndex: Int) ->LYEmoticon? {
        
        if packageIndex < 0 {
            return nil
        }
        
        guard let packages = emoticonPackages else {
            return nil
        }
        if packages.count <= packageIndex {
            return nil
        }
        
        let package = packages[packageIndex]
        if package.emoticons == nil || package.emoticons!.count == 0 {
            return nil
        }
        
        return package.emoticons![0]
    }
    
    // 选择第几个表情
    func selectedIndex(_ index: Int) {
        toolbar.selectedIndex = index
        pageControl.isHidden = false
        let package = emoticonPackages[index]
        pageControl.numberOfPages = package.emoticonGroups.count
        collectionView.scrollToItem(at: IndexPath(item: 0, section: index), at: UICollectionView.ScrollPosition(), animated: false)
    }
    
    // 保存最近的表情到缓存中
    func saveRecentEmoticon(_ emoticon: LYEmoticon) {
        
    }
    
    /// 显示贴图面板
    open func show(_ animated: Bool, completion: (() ->Void)?) {
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: { [weak self] () -> Void in
                
                guard let view = self else {
                    return
                }
                let superview = view.superview!
                var frame = view.frame
                frame.origin.y = superview.frame.height - frame.height
                view.frame = frame
                
                }, completion: { [weak self] (finished) -> Void in
                    if completion != nil {
                        let _ = completion
                    }
                    if self != nil {
                        self?.keyboardDelegate?.emoticonKeyboardDidAppear(self!)
                    }
            }) 
        } else {
            let superview = self.superview!
            var frame = self.frame
            frame.origin.y = superview.frame.height - frame.height
            self.frame = frame
            
            if completion != nil {
                let _ = completion
            }
            self.keyboardDelegate?.emoticonKeyboardDidAppear(self)
        }
        
    }
    
    /// 隐藏贴图面板
    open func hide(_ animated: Bool, completion: (() ->Void)?) {
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: { [weak self] () -> Void in
                
                guard let view = self else {
                    return
                }
                let superview = view.superview!
                var frame = view.frame
                frame.origin.y = superview.frame.height
                view.frame = frame
                
                }, completion: { [weak self] (finished) -> Void in
                    if completion != nil {
                        let _ = completion
                    }
                    if self != nil {
                        self?.keyboardDelegate?.emoticonKeyboardDidDisappear(self!)
                    }
            }) 
        } else {
            let superview = self.superview!
            var frame = self.frame
            frame.origin.y = superview.frame.height
            self.frame = frame
            
            if completion != nil {
                let _ = completion
            }
            self.keyboardDelegate?.emoticonKeyboardDidDisappear(self)
        }
        
    }

}

extension LYEmoticonKeyboard: UICollectionViewDataSource {
    
    // 多少块
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if emoticonPackages == nil {
            return 0
        }
        return emoticonPackages.count
    }
    
    // 每一块显示的子item数
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let package = emoticonPackages[section]
        let count = package.emoticonGroups.count
        if count == 0 {
            return 1
        }
        // 返回指定的
        return count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LYEmoticonCell
        cell.setup(row, column: column)
        cell.emoticonView.delegate = self
        
        let package = emoticonPackages[indexPath.section]
        if package.emoticonGroups.count > 0 {
            let emoticonGroup = package.emoticonGroups[indexPath.row]
            cell.emoticonView.emoticons = emoticonGroup.emoticons
        } else {
            cell.emoticonView.emoticons = nil
        }
        
        return cell
    }
    
}

extension LYEmoticonKeyboard: UICollectionViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        
        // 获取
        if let indexPath = collectionView.indexPathForItem(at: CGPoint(x: offsetX + collectionView.frame.size.width / 2.0, y: 0)) {
            
            toolbar.selectedIndex = indexPath.section
            
            if indexPath.section == 0 {
                // pageControl.hidden = true
            } else {
                pageControl.isHidden = false
                pageControl.numberOfPages = emoticonPackages[indexPath.section].emoticonGroups.count
                pageControl.currentPage = indexPath.item
            }
        }
    
    }
    
}

extension LYEmoticonKeyboard: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionView.frame.size
    }
    
}

extension LYEmoticonKeyboard: LYEmoticonToolbarDelegate {
    
    /// 返回指定的表情包
    public func emoticonToolbar(_ emoticonToolbar: LYEmoticonToolbar, didSelectItemAtIndex index: Int) {
        
        pageControl.isHidden = false
        let package = emoticonPackages[index]
        pageControl.numberOfPages = package.emoticonGroups.count
        
        collectionView.scrollToItem(at: IndexPath(item: 0, section: index), at: UICollectionView.ScrollPosition(), animated: false)
    }
    
}

extension LYEmoticonKeyboard: LYEmoticonViewDelegate {
    
    func emoticonView(_ emoticonView: LYEmoticonView, didSelectEmoticon emoticon: LYEmoticon) {
        
        self.keyboardDelegate?.emoticonKeyboard(self, didSelectItem: emoticon)
    }
    
}

class LYEmoticonCell: UICollectionViewCell {

    var emoticonView: LYEmoticonView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        emoticonView = LYEmoticonView(frame: CGRect.zero, size: 50)
        emoticonView.panelHeight = keyboardHeight - 40
        
        self.contentView.addSubview(emoticonView)
        
        emoticonView.translatesAutoresizingMaskIntoConstraints = false
        
        let emoticonViewKey = "emoticonView"
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[\(emoticonViewKey)]-0-|", options: [.alignAllTop], metrics: nil, views: [emoticonViewKey:emoticonView]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[\(emoticonViewKey)]-0-|", options: [.alignAllTop], metrics: nil, views: [emoticonViewKey:emoticonView]))
        
    }

    /// 避免用界面设计初始化
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(_ row: Int, column: Int) {
        emoticonView.row = row
        emoticonView.column = column
    }
    
}

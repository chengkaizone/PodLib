//
//  LYEmoticonToolbar.swift
//  LYEmoticonKeyboard
//
//  Created by tony on 16/2/24.
//  Copyright © 2016年 tony. All rights reserved.
//

import UIKit

public protocol LYEmoticonToolbarDelegate: NSObjectProtocol {
    
    // 点击的表情项
    func emoticonToolbar(_ emoticonToolbar: LYEmoticonToolbar, didSelectItemAtIndex index: Int)
    
}
/// 表情工具栏
open class LYEmoticonToolbar: UIView {

    weak var emoticonToolbarDelegate: LYEmoticonToolbarDelegate?
    
    fileprivate let reuseIdentifier = "toolbarCell"
    fileprivate var collectionView: UICollectionView!
    
    /// 显示图片还是文字 0: image 1:text default = 0
    open var type: Int = 0
    
    // 选中的item
    var selectedIndex: Int = 0 {
        didSet {
            collectionView.reloadData()
            collectionView.selectItem(at: IndexPath(item: selectedIndex, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition())
        }
    }
    
    var dataSource: [LYEmoticonPackage] = [LYEmoticonPackage]() {
        didSet {
            collectionView.reloadData()
            collectionView.selectItem(at: IndexPath(item: selectedIndex, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition())
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0.1
        
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor(red: 248/255.0, green: 248/255.0, blue: 248/255.0, alpha: 1)
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.register(LYEmoticonPosterCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        self.addSubview(collectionView)
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //addCollectionViewConstraints()
        
        let lineImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 0.5))
        lineImageView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        self.addSubview(lineImageView)
        
        lineImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    // 添加约束和
//    func addCollectionViewConstraints() {
//        let _ = collectionView.sd_layout()
//            .leftSpaceToView(self, 0)?
//            .topSpaceToView(self, 0)?
//            .rightSpaceToView(self, 0)?
//            .bottomSpaceToView(self, 0)
//    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension LYEmoticonToolbar: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return dataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LYEmoticonPosterCell
        
        let package = dataSource[indexPath.row]
        if type == 0 {
            cell.text = ""
            cell.imagePath = package.posterPath
        } else {
            cell.text = package.name
            cell.imagePath = nil
        }
  
        cell.selectFlag = indexPath.row == selectedIndex
        
        return cell
    }
    
    /// 点击cell
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if selectedIndex != indexPath.item {
            selectedIndex = indexPath.item
            emoticonToolbarDelegate?.emoticonToolbar(self, didSelectItemAtIndex: indexPath.item)
        }
    }
    
}

extension LYEmoticonToolbar: UICollectionViewDelegateFlowLayout {
    
    // MARK: 重新设置itemSize的大小
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if dataSource.count == 0 {
            return CGSize.zero
        }
        
        return CGSize(width: collectionView.bounds.height * 1.5, height: collectionView.bounds.height)
    }
    
}

class LYEmoticonPosterCell: UICollectionViewCell {
    
    fileprivate var packageItem: UIButton
    
    // 是否呗选中
    var selectFlag: Bool = false {
        didSet {
            if selectFlag {
                self.backgroundColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1)
            } else {
                self.backgroundColor = UIColor.clear
            }
        }
    }
    
    var text: String? {
        didSet {
            packageItem.setTitle(text, for: UIControl.State())
        }
    }
    
    // 设置显示图的路径
    var imagePath: String? {
        didSet {
            guard let path = imagePath else {
                packageItem.setImage(nil, for: UIControl.State())
                return
            }
            
            guard let image = UIImage(contentsOfFile: path) else {
                packageItem.setImage(nil, for: UIControl.State())
                return
            }
            
            packageItem.setImage(image, for: UIControl.State())
        }
    }
    
    override init(frame: CGRect) {
        packageItem = UIButton(type: .custom)
        packageItem.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        super.init(frame: frame)
        
        packageItem.isUserInteractionEnabled = false
        packageItem.backgroundColor = UIColor.clear
        packageItem.titleLabel?.textAlignment = .center
        packageItem.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        packageItem.imageView?.contentMode = .scaleAspectFit
        packageItem.setTitleColor(UIColor(red: 101/255.0, green: 101/255.0, blue: 101/255.0, alpha: 1), for: UIControl.State())
        
        self.addSubview(packageItem)
        
        self.selectFlag = false
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



//
//  SideBoxCollectionViewCell.swift
//  SideBoxDemo
//
//  Created by 秦 道平 on 15/11/13.
//  Copyright © 2015年 秦 道平. All rights reserved.
//

import UIKit

/// 在 cell 上拖动时发生的回调
@objc protocol SlideBoxCollectionViewCellDelegate {
    /// 拖动开始时
    func movedBeganOnCell(cell:SlideBoxCollectionViewCell)
    /// 拖动结束时，是否需要跳转到下一页
    func cell(cell:SlideBoxCollectionViewCell, completedWithRemove remove:Bool)
    /// 拖动的过程中
    func cell(cell:SlideBoxCollectionViewCell, translated translation:CGPoint)
    
}

class SlideBoxCollectionViewCell: UICollectionViewCell {
    var label : UILabel!
    var cellImageView :UIImageView!
    weak var cellDelegate : SlideBoxCollectionViewCellDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.lightGrayColor()
        self.layer.shadowColor = UIColor.darkGrayColor().CGColor
        self.layer.shadowOffset = CGSizeMake(-1.0, -1.0)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).CGPath
        /// image 
        cellImageView = UIImageView()
        cellImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(cellImageView)
        let layout_cellImageView = ["cellImageView":cellImageView]
        let cellImageView_constraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(0.0)-[cellImageView]-(0.0)-|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: layout_cellImageView)
        let cellImageView_constraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(0.0)-[cellImageView]-(0.0)-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: layout_cellImageView)
        self.contentView.addConstraints(cellImageView_constraintsH)
        self.contentView.addConstraints(cellImageView_constraintsV)
        
        /// label
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(label)
        label.textAlignment = NSTextAlignment.Center
        label.backgroundColor = UIColor.darkGrayColor()
        label.font = UIFont.systemFontOfSize(17.0)
        label.textColor = UIColor.whiteColor()
        label.text = "label"
        let layout_label = ["label":label]
        let label_constraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(0.0)-[label]-(-0.0)-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: layout_label)
        self.contentView.addConstraints(label_constraintsH)
        let label_constraints_height = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 30.0)
        self.contentView.addConstraint(label_constraints_height)
        let label_constraints_v = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0)
        self.contentView.addConstraint(label_constraints_v)
        /// panGesture
        let panGesture = UIPanGestureRecognizer(target: self, action: "onPanGesture:")
        panGesture.delegate = self
        self.contentView.addGestureRecognizer(panGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
extension SlideBoxCollectionViewCell : UIGestureRecognizerDelegate {
    func onPanGesture(gesture:UIPanGestureRecognizer){
        if gesture.state == UIGestureRecognizerState.Began {
            self.cellDelegate?.movedBeganOnCell(self)
        }
        else if gesture.state == UIGestureRecognizerState.Ended || gesture.state == UIGestureRecognizerState.Cancelled {
            let translate = gesture.translationInView(self.contentView)
            /// 拖动的距离太小，回到原来的位置
            if translate.y > -1 * self.bounds.size.height * 0.5 {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.transform = CGAffineTransformIdentity
                    }, completion: { (completed) -> Void in
                })
                self.cellDelegate?.cell(self, completedWithRemove: false) /// 动画结束后修正位置
            }
            else{ /// 只可以往上拖动（左右是滚动）, 距离足够大的话就实现删除效果
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    var targetOffsetX : CGFloat = 0.0
                    if translate.x > 0 {
                        targetOffsetX = self.bounds.size.width
                    }
                    else {
                        targetOffsetX = -1 * self.bounds.size.width
                    }
                    let targetOffsetY : CGFloat = -1 * self.bounds.size.height
                    let translate_transform = CGAffineTransformMakeTranslation(targetOffsetX, targetOffsetY)
                    let angle : CGFloat = 0.0
                    let radian = -angle * CGFloat(M_PI) / 180.0 * 2.0
                    self.transform = CGAffineTransformRotate(translate_transform, radian)
                    self.alpha = 0.0
                    }, completion: { (completed) -> Void in
                        self.cellDelegate?.cell(self, completedWithRemove: true) /// 动画结束后修正位置，实现真正的删除
                })
            }
        }
        /// 拖动的过程中
        else if gesture.state == UIGestureRecognizerState.Changed {
            let translate = gesture.translationInView(self.contentView)
            let translate_transform = CGAffineTransformMakeTranslation(translate.x, translate.y)
            var angle : CGFloat = 0.0
            if abs(translate.x) > 20.0 { /// 横向拖动要足够大的距离，不然在中间位置时会跳动
                angle = atan(translate.y / translate.x)
//                print("x:\(translate.x),y:\(translate.y),angle:\(angle)")
            }
            let radian = -angle * CGFloat(M_PI) / 180.0 * 2.0
            self.transform = CGAffineTransformRotate(translate_transform, radian)
            self.cellDelegate?.cell(self, translated: translate) /// 拖动过程中，对其他 cell 要同步修正位置
        }
        
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        let translate = panGesture.translationInView(self.contentView)
        return abs(translate.y) > abs(translate.x)
    }
}


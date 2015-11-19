//
//  SideBoxCollectionViewCell.swift
//  SideBoxDemo
//
//  Created by 秦 道平 on 15/11/13.
//  Copyright © 2015年 秦 道平. All rights reserved.
//

import UIKit

@objc protocol SideBoxCollectionViewCellDelegate {
    func movedBeganOnCell(cell:SideBoxCollectionViewCell)
    func cell(cell:SideBoxCollectionViewCell, movedToNext toNext:Bool)
    func cell(cell:SideBoxCollectionViewCell, translated translation:CGPoint)
    
}

class SideBoxCollectionViewCell: UICollectionViewCell {
    var label : UILabel!
    var cellImageView :UIImageView!
    weak var cellDelegate : SideBoxCollectionViewCellDelegate?
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
extension SideBoxCollectionViewCell : UIGestureRecognizerDelegate {
    func onPanGesture(gesture:UIPanGestureRecognizer){
        if gesture.state == UIGestureRecognizerState.Began {
            self.cellDelegate?.movedBeganOnCell(self)
        }
        else if gesture.state == UIGestureRecognizerState.Ended || gesture.state == UIGestureRecognizerState.Cancelled {
            let translate = gesture.translationInView(self.contentView)
            if translate.y > -1 * self.bounds.size.height * 0.5 {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.transform = CGAffineTransformIdentity
                    }, completion: { (completed) -> Void in
                        self.cellDelegate?.cell(self, movedToNext: false)
                })
            }
            else{
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    var targetOffsetX : CGFloat = 0.0
                    if translate.x > 0 {
                        targetOffsetX = self.bounds.size.width
                    }
                    else {
                        targetOffsetX = -1 * self.bounds.size.width
                    }
                    let targetOffsetY : CGFloat = -1 * self.bounds.size.height
                    self.transform = CGAffineTransformMakeTranslation(targetOffsetX, targetOffsetY)
                    self.alpha = 0.0
                    }, completion: { (completed) -> Void in
                        self.cellDelegate?.cell(self, movedToNext: true)
                        
                })
            }
        }
        else if gesture.state == UIGestureRecognizerState.Changed {
            let translate = gesture.translationInView(self.contentView)
            let translate_transform = CGAffineTransformMakeTranslation(translate.x, translate.y)
            var angle : CGFloat = 0.0
            if abs(translate.x) > 20.0 {
                angle = atan(translate.y / translate.x)
//                print("x:\(translate.x),y:\(translate.y),angle:\(angle)")
            }
            let radian = -angle * CGFloat(M_PI) / 180.0 * 2.0
            self.transform = CGAffineTransformRotate(translate_transform, radian)
            self.cellDelegate?.cell(self, translated: translate)
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


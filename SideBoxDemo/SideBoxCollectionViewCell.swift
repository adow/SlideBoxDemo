//
//  SideBoxCollectionViewCell.swift
//  SideBoxDemo
//
//  Created by 秦 道平 on 15/11/13.
//  Copyright © 2015年 秦 道平. All rights reserved.
//

import UIKit

class SideBoxCollectionViewCell: UICollectionViewCell {
    var label : UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.lightGrayColor()
        self.layer.shadowColor = UIColor.darkGrayColor().CGColor
        self.layer.shadowOffset = CGSizeMake(-1.0, -1.0)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).CGPath
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
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

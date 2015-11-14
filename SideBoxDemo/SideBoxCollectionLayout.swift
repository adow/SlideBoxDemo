//
//  SideBoxCollectionLayout.swift
//  SideBoxDemo
//
//  Created by 秦 道平 on 15/11/13.
//  Copyright © 2015年 秦 道平. All rights reserved.
//

import UIKit

func divmod(a:CGFloat,b:CGFloat) -> (quotient:CGFloat, remainder:CGFloat){
    return (a / b, a % b)
}

class SideBoxCollectionLayout: UICollectionViewFlowLayout {
    private let pageDistance : CGFloat = ceil(UIScreen.mainScreen().bounds.width * 0.5 + UIScreen.mainScreen().bounds.width * 0.6)
    private let cardWidth : CGFloat = UIScreen.mainScreen().bounds.width * 0.6
    private let cardHeight : CGFloat = UIScreen.mainScreen().bounds.height * 0.6
    private var attributesList : [UICollectionViewLayoutAttributes] = []
    private var targetOffsetX : CGFloat = 0.0
    override init() {
        super.init()
        self.scrollDirection = UICollectionViewScrollDirection.Horizontal
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func collectionViewContentSize() -> CGSize {
        let numberOfItems = self.collectionView!.numberOfItemsInSection(0)
        return CGSizeMake(self.pageDistance * CGFloat(numberOfItems) + self.collectionView!.bounds.width,
            self.collectionView!.bounds.width)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        var array : [UICollectionViewLayoutAttributes] = []
        let numberOfItems = self.collectionView!.numberOfItemsInSection(0)
        let offset_x = self.collectionView!.contentOffset.x
        let center_x : CGFloat = self.collectionView!.bounds.width / 2.0 + offset_x
        let center_y : CGFloat = self.collectionView!.bounds.height / 2.0
        let center = CGPointMake(center_x, center_y)
        for a in 0..<numberOfItems {
            let bounds = CGRectMake(0.0, 0.0, self.cardWidth, self.cardHeight)
            let ratio = 1.0 - ( CGFloat(a) * 0.1) + (offset_x / pageDistance) / 10.0
            let indexPath = NSIndexPath(forItem: a, inSection: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            attributes.center = center
            attributes.bounds = bounds
            attributes.zIndex = 10000 - a
            let scale = max(min(1.1, ratio), 0.0)
            let transform_scale = CGAffineTransformMakeScale(scale, scale)
//            let transform_scale = CGAffineTransformIdentity
            if ratio > 1.0 {
                var translate : CGFloat!
                if ratio >= 1.1 {
//                    translate = -1.0 * center_x + self.cardWidth / 2.0
                    translate = -1.0 * (self.collectionView!.bounds.width / 2.0 + self.cardWidth / 2.0)
//                    translate = -300.0
                }
                else {
                    translate = -1.0 * offset_x % pageDistance
                    if translate == 0.0 {
                        translate = -pageDistance
                    }
//                    translate = -1.0 * (offset_x - self.targetOffsetX)
                }
                print("\(a),\(ratio),\(scale), \(translate)")
                attributes.transform = CGAffineTransformTranslate(transform_scale, translate, 0.0)
            }
            else {
                print("\(a),\(ratio),\(scale)")
                attributes.transform = transform_scale
                
            }
        
            array.append(attributes)
        }
        self.attributesList = array
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.attributesList
    }
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return self.attributesList[indexPath.row]
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
//        NSLog("propsed:\(proposedContentOffset),velocity:\(velocity),offset:\(self.collectionView!.contentOffset)")
        var targetContentOffset = proposedContentOffset
        if abs(self.collectionView!.contentOffset.x - proposedContentOffset.x) >= 30.0 {
            if velocity.x > 0.0 {
                    self.targetOffsetX += self.pageDistance
            }
            else {
                self.targetOffsetX -= self.pageDistance
            }
            self.targetOffsetX = max(self.targetOffsetX, 0.0)
            self.targetOffsetX = min(self.collectionView!.contentSize.width - self.collectionView!.bounds.width, self.targetOffsetX)
        }
        targetContentOffset.x = self.targetOffsetX
        NSLog("targetOffsetX:%f",self.targetOffsetX)
        return targetContentOffset
//        var targetContentOffset = proposedContentOffset
//        let y_distance_in_cells = self.pageDistance
//        let (total,more) = divmod(targetContentOffset.x, b: y_distance_in_cells)
//        if more > 0.0 {
//            if more >= y_distance_in_cells / 2.0 {
//                targetContentOffset.x = ceil(total) * y_distance_in_cells
//            }
//            else {
//                targetContentOffset.x = floor(total) * y_distance_in_cells
//            }
//        }
//        return targetContentOffset
    }
}

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

class SlideBoxCollectionLayoutAttributes:UICollectionViewLayoutAttributes {
    var ratio:CGFloat! {
        didSet{
            let scale = max(min(1.1, ratio), 0.0)
            let transform_scale = CGAffineTransformMakeScale(scale, scale)
            if ratio > 1.0 {
                var translate : CGFloat!
                if ratio >= 1.1 {
                    translate = -1.0 * (self.screenSize.width / 2.0 + self.cardWidth / 2.0)
                }
                else {
                    translate = -1.0 * (ratio - floor(ratio)) * pageDistance * 10.0
                    if translate == 0.0 {
                        translate = -pageDistance
                    }
                }
//                print("\(a),\(ratio),\(scale), \(translate)")
                self.transform = CGAffineTransformTranslate(transform_scale, translate, 0.0)
            }
            else {
//                print("\(a),\(ratio),\(scale)")
                self.transform = transform_scale
                
            }
            
        }
    }
    lazy var screenSize:CGSize = UIScreen.mainScreen().bounds.size
    var pageDistance:CGFloat!
    var cardWidth:CGFloat!
    var cardHeight:CGFloat!
   
    class func attribuatesForIndexPath(indexPath:NSIndexPath, pageDistance:CGFloat, cardWidth:CGFloat,cardHeight: CGFloat) -> SlideBoxCollectionLayoutAttributes{
        let attributes = SlideBoxCollectionLayoutAttributes(forCellWithIndexPath: indexPath)
        attributes.pageDistance = pageDistance
        attributes.cardWidth = cardWidth
        attributes.cardHeight = cardHeight
        return attributes
    }
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! SlideBoxCollectionLayoutAttributes
        copy.screenSize = self.screenSize
        copy.pageDistance = self.pageDistance
        copy.cardWidth = self.cardWidth
        copy.cardHeight = self.cardHeight
        copy.ratio = ratio
        return copy
    }
}

class SlideBoxCollectionLayout: UICollectionViewFlowLayout {
    let pageDistance : CGFloat = ceil(UIScreen.mainScreen().bounds.width * 0.5 + UIScreen.mainScreen().bounds.width * 0.6)
    let cardWidth : CGFloat = UIScreen.mainScreen().bounds.width * 0.9
    let cardHeight : CGFloat = UIScreen.mainScreen().bounds.height * 0.9
    private var attributesList : [UICollectionViewLayoutAttributes] = []
    /// 用来在滚动时限定在一个固定的位置
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
        let bounds = CGRectMake(0.0, 0.0, self.cardWidth, self.cardHeight)
        for a in 0..<numberOfItems {
            /// 计算 ratio, ratio 使用来确定真正位置的参数，每个 cell 直接差 0.1,还要计算当前滚动的位置
            let ratio = 1.0 - ( CGFloat(a) * 0.1) + (offset_x / pageDistance) / 10.0
            let indexPath = NSIndexPath(forItem: a, inSection: 0)
            let attributes = SlideBoxCollectionLayoutAttributes.attribuatesForIndexPath(indexPath, pageDistance: pageDistance, cardWidth: cardWidth, cardHeight: cardHeight)
            attributes.center = center
            attributes.bounds = bounds
            attributes.zIndex = 10000 - a
            attributes.ratio = ratio
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
    override class func layoutAttributesClass() -> AnyClass {
        return SlideBoxCollectionViewCell.self
    }
    /// 确保每次只滚动一页的距离，不管实际滚动多少，只要和上一次位置距离超过 30 就进行页面跳转(滚动)
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
//        NSLog("propsed:\(proposedContentOffset),velocity:\(velocity),offset:\(self.collectionView!.contentOffset)")
        var targetContentOffset = proposedContentOffset
        if abs(self.collectionView!.contentOffset.x - proposedContentOffset.x) >= 30.0 {
            /// 往后一页
            if velocity.x > 0.0 {
                    self.targetOffsetX += self.pageDistance
            }
            /// 往前一页
            else {
                self.targetOffsetX -= self.pageDistance
            }
            self.targetOffsetX = max(self.targetOffsetX, 0.0)
            self.targetOffsetX = min(self.collectionView!.contentSize.width - self.collectionView!.bounds.width, self.targetOffsetX)
        }
        /// 如果滚动距离太小，就回到原来的位置
        targetContentOffset.x = self.targetOffsetX
//        NSLog("targetOffsetX:%f",self.targetOffsetX)
        return targetContentOffset
    }
    override func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
//        print("disappearing:\(itemIndexPath.row)")
        return nil
    }
}

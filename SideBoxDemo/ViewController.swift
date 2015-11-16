//
//  ViewController.swift
//  SideBoxDemo
//
//  Created by 秦 道平 on 15/11/13.
//  Copyright © 2015年 秦 道平. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var collectionView : UICollectionView!
    private let cellIdentifier = "cell"
    var panGesture:UIPanGestureRecognizer!
    var contentOffsetX_onPanBegan : CGFloat!
    var cellSnapShot:UIView!
    var indexPathSnapShot:NSIndexPath!
    var cellTexts:[String]!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.prepareData()
        /// collectionView
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: SideBoxCollectionLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.showsHorizontalScrollIndicator = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        self.view.addSubview(collectionView)
        let collectionView_layout = ["collectionView":collectionView]
        let collection_constraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(0.0)-[collectionView]-(0.0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: collectionView_layout)
        let collection_constraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(0.0)-[collectionView]-(0.0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: collectionView_layout)
        self.view.addConstraints(collection_constraintsH)
        self.view.addConstraints(collection_constraintsV)
        self.collectionView.registerClass(SideBoxCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        /// panGesture
        panGesture = UIPanGestureRecognizer(target: self, action: "onPanGesture:")
        panGesture.delegate = self
        self.view.addGestureRecognizer(panGesture)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.layoutIfNeeded()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    private func prepareData(){
        self.cellTexts = [String]()
        for a in 0..<30 {
            let txt = "Card - \(a)"
            self.cellTexts.append(txt)
        }
    }


}
extension ViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cellTexts.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! SideBoxCollectionViewCell
//        cell.label.text = "Card - \(indexPath.row)"
        let txt = self.cellTexts[indexPath.row]
        cell.label.text = txt
        return cell
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        NSLog("scroll:%f",scrollView.contentOffset.x)
    }
}
extension ViewController {
    private func makeCellSnapView(){
        let layout = self.collectionView.collectionViewLayout as! SideBoxCollectionLayout
        let cardIndex = Int(floor(self.collectionView.contentOffset.x / layout.pageDistance))
        let pathIndex = NSIndexPath(forItem: cardIndex, inSection: 0)
        self.indexPathSnapShot = pathIndex
        let cell = self.collectionView.cellForItemAtIndexPath(pathIndex)!
        self.cellSnapShot = cell.snapshotViewAfterScreenUpdates(true)
//        self.cellSnapShot.alpha = 0.3
        self.cellSnapShot.center = self.view.center
        self.cellSnapShot.bounds = CGRectMake(0.0, 0.0, layout.cardWidth, layout.cardHeight)
        self.cellSnapShot.userInteractionEnabled = false
        self.view.addSubview(self.cellSnapShot)
        
    }
}
extension ViewController:UIGestureRecognizerDelegate {
    func onPanGesture(gesture:UIPanGestureRecognizer){
        if gesture.state == UIGestureRecognizerState.Began {
            NSLog("Began Move")
            self.makeCellSnapView()
            self.contentOffsetX_onPanBegan = self.collectionView.contentOffset.x
            let layout = self.collectionView.collectionViewLayout as! SideBoxCollectionLayout
            layout.stopScrollForTopCards = true
        }
        else if gesture.state == UIGestureRecognizerState.Ended || gesture.state == UIGestureRecognizerState.Cancelled {
            NSLog("End Move")
            let layout = self.collectionView.collectionViewLayout as! SideBoxCollectionLayout
            let translate = gesture.translationInView(self.view)
            /// 如果拖动距离太短就退回到原来的位置,滚动条也返回到原来的位置
            if translate.y > -1 * layout.pageDistance / 2.0 {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.cellSnapShot.transform = CGAffineTransformIdentity
                    }, completion: { (completed) -> Void in
                    self.cellSnapShot.removeFromSuperview()
                    layout.stopScrollForTopCards = false
                })
                let contentOffset = CGPointMake(self.contentOffsetX_onPanBegan, 0.0)
                self.collectionView.setContentOffset(contentOffset, animated: true)
            }
            else { /// 否则就滚动到下一个位置
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.cellSnapShot.transform = CGAffineTransformMakeTranslation(translate.x, -1 * layout.pageDistance)
                    self.cellSnapShot.alpha = 0.0
                    }, completion: { (completed) -> Void in
                        self.cellSnapShot.removeFromSuperview()
                        
                })
                
//                let contentOffsetX = self.contentOffsetX_onPanBegan + layout.pageDistance
//                let contentOffset = CGPointMake(contentOffsetX, 0.0)
//                self.collectionView.setContentOffset(contentOffset, animated: true)
                
                let contentOffset = CGPointMake(self.contentOffsetX_onPanBegan, 0.0)
                self.collectionView.setContentOffset(contentOffset, animated: false)
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
//                    self.collectionView.performBatchUpdates({ () -> Void in
//                        self.cellTexts.removeAtIndex(self.indexPathSnapShot.row)
//                        self.collectionView.deleteItemsAtIndexPaths([self.indexPathSnapShot,])
//                        }, completion: { (completed) -> Void in
//                            layout.stopScrollForTopCards = false
//                    })
//                    
//                    
//                }
                self.collectionView.performBatchUpdates({ () -> Void in
                    self.cellTexts.removeAtIndex(self.indexPathSnapShot.row)
                    self.collectionView.deleteItemsAtIndexPaths([self.indexPathSnapShot,])
                    }, completion: { (completed) -> Void in
                        layout.stopScrollForTopCards = false
                })

            }
        }
        else if gesture.state == UIGestureRecognizerState.Changed {
            let translate = gesture.translationInView(self.view)
            /// scroll
            let contentOffsetX = self.contentOffsetX_onPanBegan + (-1 * translate.y)
            let contentOffset = CGPointMake(contentOffsetX, 0.0)
            self.collectionView.setContentOffset(contentOffset, animated: true)
            /// pan
            self.cellSnapShot.transform = CGAffineTransformMakeTranslation(translate.x, translate.y)
        }
    }
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        let translate = panGesture.translationInView(self.view)
        return abs(translate.y) > abs(translate.x)
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
extension ViewController:SideBoxCollectionViewCellDelegate {
    func movedBeganOnCell(cell: SideBoxCollectionViewCell) {
        NSLog("Began Move")
        let layout = self.collectionView.collectionViewLayout as! SideBoxCollectionLayout
        layout.stopScrollForTopCards = true
        self.contentOffsetX_onPanBegan = self.collectionView.contentOffset.x
    }
    func movedEndedOnCell(cell: SideBoxCollectionViewCell) {
        NSLog("End Move")
        let layout = self.collectionView.collectionViewLayout as! SideBoxCollectionLayout
        layout.stopScrollForTopCards = false
        let contentOffsetX = self.contentOffsetX_onPanBegan + layout.pageDistance
        self.collectionView.setContentOffset(CGPointMake(contentOffsetX, 0.0), animated: true)

    }
    func cell(cell: SideBoxCollectionViewCell, translated translation: CGPoint) {
        let contentOffsetX = self.contentOffsetX_onPanBegan + translation.y
        let contentOffset = CGPointMake(contentOffsetX, 0.0)
        self.collectionView.setContentOffset(contentOffset, animated: true)
    }
}

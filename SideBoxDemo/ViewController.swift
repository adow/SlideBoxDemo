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
    var cellTexts:[String]!
    var cellImages:[UIImage]!
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
        self.cellImages = [UIImage]()
        for a in 0..<30 {
            let txt = "Card - \(a)"
            self.cellTexts.append(txt)
            let imageIndex = a % 5
            let imageName = "cell-\(imageIndex)"
            let image = UIImage(named: imageName)!
            self.cellImages.append(image)
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
        cell.cellDelegate = self
        let txt = self.cellTexts[indexPath.row]
        cell.label.text = txt
        let image = self.cellImages[indexPath.row]
        cell.cellImageView.image = image
        return cell
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        NSLog("scroll:%f",scrollView.contentOffset.x)
    }
}

// MARK: - Move on cell
extension ViewController:SideBoxCollectionViewCellDelegate {
    /// 取得拖动的 cell 的下面一个 cell
    private func nextCell() -> SideBoxCollectionViewCell?{
        let layout = self.collectionView.collectionViewLayout as! SideBoxCollectionLayout
        let cardIndex = Int(floor(self.collectionView.contentOffset.x / layout.pageDistance))
        let nextIndexPath = NSIndexPath(forItem: cardIndex + 1, inSection: 0)
        return self.collectionView.cellForItemAtIndexPath(nextIndexPath) as? SideBoxCollectionViewCell
    }
    func movedBeganOnCell(cell: SideBoxCollectionViewCell) {
//        NSLog("Began Move")
    }
    func cell(cell: SideBoxCollectionViewCell, movedToNext toNext: Bool) {
//        NSLog("End Move")
        let layout = self.collectionView.collectionViewLayout as! SideBoxCollectionLayout
        /// 删除这个cell
        if toNext {
            let cardIndex = Int(floor(self.collectionView.contentOffset.x / layout.pageDistance))
            let indexPath = NSIndexPath(forItem: cardIndex, inSection: 0)
            self.cellTexts.removeAtIndex(cardIndex)
            self.cellImages.removeAtIndex(cardIndex)
            self.collectionView.deleteItemsAtIndexPaths([indexPath,])
        }
        else { /// 不用删除这个 cell, 回到原来的位置
            if let nextCell = self.nextCell(){
                nextCell.transform = CGAffineTransformIdentity
            }
        }
    }
    func cell(cell: SideBoxCollectionViewCell, translated translation: CGPoint) {
        let layout = self.collectionView.collectionViewLayout as! SideBoxCollectionLayout
        /// 在移动当前这个 cell 时，要根据拖动的距离来修正下面一个 cell 的位置，使他看上去再变大
        if let nextCell = self.nextCell() {
            let scale = max(min(0.9 + fabs(translation.y / layout.pageDistance) / 10.0 ,1.0),0.0) /// 因为下面一个 cell 开始时是 0.9
            nextCell.transform = CGAffineTransformMakeScale(scale, scale)
            
        }
    }
}

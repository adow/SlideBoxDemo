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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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


}
extension ViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! SideBoxCollectionViewCell
        cell.label.text = "Card - \(indexPath.row)"
        return cell
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        NSLog("scroll:%f",scrollView.contentOffset.x)
    }
}


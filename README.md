# SlideBoxDemo

Slidebox 是 iOS 上一个用来管理照片的 App，他一张张的滑动方式浏览，把不需要的照片往上滑动就是删除这一张，如果相册中拍了很多类似的照片，通过这样的方式来筛选照片是个不错的主意。

![SideBox](http://7vihfk.com1.z0.glb.clouddn.com/thumb_IMG_3303_1024.jpg)

所以我模仿 SlideBox 写了这个 Demo，左右滑动显示照片，往上就删除这张照片。

> 大坑警告。这个 Demo 使用 UICollectionView 来实现这个效果，但是这并不是最优的方案，实际上这个效果直接使用 UIScrollView 就可以轻松合理的实现了，我使用 UICollectionView 只是为了学习研究而已。

![SlideBoxDemo](http://7vihfk.com1.z0.glb.clouddn.com/SlideBoxDemo2.mov.gif)

## 实现左右切换

由于使用 UICollectionView 来实现这个效果，所以最重要的是实现 UICollectionViewLayout，其中是用来完成每个 Cell 位置计算。

我实现了 SlideBoxCollectionLayout

在 `prepareLayout()` 中完成了所有 Cell 的 UICollectionViewLayoutAttributes 创建。我自定义了 `SlideBoxCollectionLayoutAttributes` 来存储自定义的属性，其中最重要的是 `ratio` 属性，他用来完成每个 Cell 的位置计算。

在开始的时候，所有的 Cell 都在屏幕的中间，他们通过 z-index 设置遮挡关系。后面的 Cell 比前面的 Cell 总是缩小 0.1。我们用 ratio 来计算每个 Cell 的位置，除了每个 Cell 之间需要有 0.1 外，还需要考虑到滚动时的效果，当每滚动一个距离后，前面的 Cell 到屏幕外面，后面的 Cell 正好到达之前 Cell 的位置。所以 ratio 的计算是最主要的:

	let ratio = 1.0 - ( CGFloat(a) * 0.1) + (offset_x / pageDistance) / 10.0

`ratio` 具体影响了 Cell 的缩放和位置偏移，在屏幕正中间的时候 `ratio = 1.0`，越往后面的 Cell 会越来越小，但是他们都是在屏幕的中间的。我们还定义了当现在显示的这个 Cell 移动到屏幕外面的时候 `ratio` 正好是 1.1, 这时下面的一个 Cell 取代了原来的位置。

当 `SlideBoxCollectionLayoutAttributes` 的 `ratio` 值被修改的时候，会同时修改 `transform` 属性:

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

### SlideBoxCollectionLayoutAttributes 是需要 copy 的

当使用 UICollectionViewLayoutAttributes 的自定义属性时，他必须实现 copyWithZone 方法来实现属性的拷贝

	override func copyWithZone(zone: NSZone) -> AnyObject {
		let copy = super.copyWithZone(zone) as! SlideBoxCollectionLayoutAttributes
		copy.screenSize = self.screenSize
		copy.pageDistance = self.pageDistance
		copy.cardWidth = self.cardWidth
		copy.cardHeight = self.cardHeight
		copy.ratio = ratio
		return copy
	    }

### 限制的滚动

由于 UICollectionView/UIScrollView 在滚动时是根据开始时的拖动速度来确定的，所以他无法达到我们需要的每次只拖动到下一张图的效果。我们必须实现 targetContentOffsetForProposedContentOffset 来限制滚动的距离。

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


## 实现拖动删除

当上下拖动当前显示的这个 Cell 时，我们是在这个 Cell 上添加了 UIPanGestureRecognizer 来实现拖动 Cell 的。当拖动到一个足够的位置时，我们松开的时候就会删除这个 Cell, 同时你会看到当我们拖动这个 Cell 的时候，下面一层的 Cell 其实会逐渐变大， 这些都要求处理手势的时候有一些通知到外部的方法来同步状态。

	/// 在 cell 上拖动时发生的回调
	@objc protocol SlideBoxCollectionViewCellDelegate {
	    /// 拖动开始时
	    func movedBeganOnCell(cell:SlideBoxCollectionViewCell)
	    /// 拖动结束时，是否需要跳转到下一页
	    func cell(cell:SlideBoxCollectionViewCell, completedWithRemove remove:Bool)
	    /// 拖动的过程中
	    func cell(cell:SlideBoxCollectionViewCell, translated translation:CGPoint)
	    
	}


当 Cell 被拖动的时候, 需要让下面的 Cell 变大

		func cell(cell: SlideBoxCollectionViewCell, completedWithRemove remove: Bool) {
	//        NSLog("End Move")
			let layout = self.collectionView.collectionViewLayout as! SlideBoxCollectionLayout
			/// 删除这个cell
			if remove {
			    let cardIndex = Int(floor(self.collectionView.contentOffset.x / layout.pageDistance))
			    let indexPath = NSIndexPath(forItem: cardIndex, inSection: 0)
			    self.cellTexts.removeAtIndex(cardIndex)
			    self.cellImages.removeAtIndex(cardIndex)
			    self.collectionView.deleteItemsAtIndexPaths([indexPath,])
			}
			else { /// 不用删除这个 cell, 回到原来的位置
			    if let nextCell = self.nextCell(){
				UIView.animateWithDuration(0.3, animations: { () -> Void in
				    nextCell.transform = CGAffineTransformMakeScale(0.9, 0.9)
				})
			    }
			}
		    }

当拖动结束的时候，需要确定是不是真的要删除这个 Cell

	func cell(cell: SlideBoxCollectionViewCell, translated translation: CGPoint) {
		let layout = self.collectionView.collectionViewLayout as! SlideBoxCollectionLayout
		/// 在移动当前这个 cell 时，要根据拖动的距离来修正下面一个 cell 的位置，使他看上去再变大
		if let nextCell = self.nextCell() {
		    let scale = max(min(0.9 + fabs(translation.y / layout.pageDistance) / 10.0 ,1.0),0.0) /// 因为下面一个 cell 开始时是 0.9
		    nextCell.transform = CGAffineTransformMakeScale(scale, scale)
		    
		}
	    }
	    
## 全部实现代码

* [SlideBoxDemo](https://github.com/adow/SlideBoxDemo)

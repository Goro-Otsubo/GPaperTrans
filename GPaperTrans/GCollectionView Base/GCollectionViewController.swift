//
//  GCollectionViewController.swift
//  GPaperTrans
//
//  Created by Goro Otsubo on 2014/11/14.
//  Copyright (c) 2014 Goro Otsubo. All rights reserved.
//

import UIKit

let reuseIdentifier = "GCell"           //identifier for cell with ASImageNode
let synReuseIdentifier = "SyncGCell"    //identifier for cell with UIImageView

//Base UICollectionViewController class
//also serves as view controller for magnified view

class GCollectionViewController: UICollectionViewController,UIGestureRecognizerDelegate {
    var asyncNodeFlag:Bool                      //if true, use GCollectioniViewCell and pop
    var initialPanPoint:CGPoint                 // record the point where pan began
    var shortLayout:UICollectionViewFlowLayout  //layout for short height collectionViewCell
    var tallLayout:UICollectionViewFlowLayout   //layout for tall height collectionViewCell
    var toBeExpandedFlag:Bool                   //true if transition from short to tall. false if otherwise
    var targetY:CGFloat                         //if the touch point moved to this y values, progress should be 1.0
    var panRecog:UIPanGestureRecognizer?
    var transitioningFlag = false               //true from collectioView.startInt.. to finishUpInteraction
    var changedFlag = false                     //true if UIGestureRecognizerState.Changed  after interaction began
    var initxOffset:CGFloat                     //xoffset for UICollectionView when transition began
    var xOffset:CGFloat                         //xoffset for UICollectioinView while changing
    var touchedCell:UICollectionViewCell?       //the cell which user touched at first
    var initXCell:CGFloat                       //frame.origin.x of cell when user touched
    var tgtXCell:CGFloat                        //frame.origin.x of cell when transaction will finish
    var xWhenReleased:CGFloat                   //x of touch point when user released the finger
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        
        self.asyncNodeFlag = true           //default value. will be set by 
                                            //GRootViewController in viewDidLoad
        self.initialPanPoint = CGPointZero
        self.toBeExpandedFlag = true
        self.targetY = 0
        self.shortLayout = UICollectionViewFlowLayout()
        self.tallLayout = UICollectionViewFlowLayout()
        self.panRecog = nil
        
        self.initxOffset = 0
        self.initXCell = 0
        self.tgtXCell = 0
        self.xOffset = 0
        self.touchedCell = nil
        self.xWhenReleased = 0

        super.init(collectionViewLayout: layout)
        
        self.collectionView?.removeFromSuperview()
        
        self.collectionView = GCollectionView(frame: CGRectZero, collectionViewLayout: layout)
        self.collectionView?.dataSource = self
        self.view.addSubview(self.collectionView!)

        // Register cell classes
        self.collectionView?.registerClass(GCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.registerClass(GSyncViewCell.self, forCellWithReuseIdentifier: synReuseIdentifier)
        
        //Gesture recognizer
        self.panRecog = UIPanGestureRecognizer(target: self, action: "handlePan:")
        panRecog!.delegate = self

        self.collectionView?.addGestureRecognizer(panRecog!)

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.frame = self.view.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }



    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100 // just arbitary value
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if asyncNodeFlag{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! GCollectionViewCell
            cell.setIndex(indexPath.row, size: toBeExpandedFlag ? shortLayout.itemSize : tallLayout.itemSize)
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(synReuseIdentifier, forIndexPath: indexPath) as! GSyncViewCell
            cell.setIndex(indexPath.row, size:  toBeExpandedFlag ? shortLayout.itemSize : tallLayout.itemSize)
            return cell
        }
    }


    

    override func collectionView(collectionView: UICollectionView,
        transitionLayoutForOldLayout fromLayout: UICollectionViewLayout,
        newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout
    {
        let ret = GTransLayout(currentLayout:fromLayout, nextLayout: toLayout)
        return ret
        
    }
    
    func removeAnimation(){
        
        //completionBlock is executed when animation is removed.
        //therefore, make completionBlock nil before removal
        
        let anim: POPBasicAnimation? = self.pop_animationForKey("animation") as! POPBasicAnimation?

        if anim != nil{
            anim!.completionBlock = nil
        }
        self.pop_removeAllAnimations()
    }

    // MARK: Gesture recognizer related
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if(gestureRecognizer === self.panRecog) {
            let panRecog = gestureRecognizer as! UIPanGestureRecognizer
            let direction = panRecog.velocityInView(panRecog.view)
            let pos = panRecog.locationInView(panRecog.view)
            
            //if touch point of out of range of cell, return false
            if toBeExpandedFlag {
                if CGRectGetHeight(self.collectionView!.frame) - shortLayout.itemSize.height > pos.y{
                    return false
                }
            }
            
            // if swipe for vertical direction, returns true
            
            if abs(direction.y) >  abs(direction.x)  {
                return true
            }
            else{
                return false
            }
        }
        else{
            return true
        }
    }

    
    func handlePan(sender:UIPanGestureRecognizer){
        
        var point = sender.locationInView(sender.view?.superview)
        let velocity = sender.velocityInView(sender.view)
        
        //limit the range of velocity so that animation will not stop when verlocity is 0
        
        let yVelocity = CGFloat(max(min(abs(velocity.y),80.0),20.0))
        
        var progress = max(min(abs(point.y - initialPanPoint.y)/abs(targetY - initialPanPoint.y),1.0),0.0)
        if toBeExpandedFlag{
            if point.y > initialPanPoint.y {
                progress = 0.0
            }
            else if point.y < targetY {
                progress = 1.0
            }
        }
        else{
            if point.y < initialPanPoint.y {
                progress = 0.0
            }
            else if point.y > targetY {
                progress = 1.0
            }
        }

        switch sender.state{
            
        case UIGestureRecognizerState.Began:
            
            changedFlag = false     //clear flag here
            
            if let transLayout = getTransitionLayout(){
                //animation is interrupted by user action
                //initialPoint.y and targetY has to be updated according to progress 
                //and touched position
                updatePositionData(point,progress: transLayout.transitionProgress)
                return;
            }
            if (velocity.y > 0 && toBeExpandedFlag) || (velocity.y < 0 && !toBeExpandedFlag) {
                //only respond to one direction of swipe
                return
            }

            self.initialPanPoint = point    // record the point where gesture began
            
            let tallHeight = tallLayout.itemSize.height
            let shortHeight = shortLayout.itemSize.height
            
            var hRatio = (tallHeight - self.initialPanPoint.y) / (self.toBeExpandedFlag ? shortHeight : tallHeight)
            
            // when the touch point.y reached targetY, that meanas progress = 1.0
            // update targetY value
            
            self.targetY = tallHeight - hRatio * (self.toBeExpandedFlag ? tallHeight : shortHeight)
            
            self.initxOffset = self.collectionView!.contentOffset.x

            //self.tLayout =
            self.collectionView?.startInteractiveTransitionToCollectionViewLayout(
                    toBeExpandedFlag ? tallLayout : shortLayout,
                    completion: { completed, finished in
                        if !self.asyncNodeFlag {
                            self.startGesture()
                        }
                        println("completion block called")
                        (self.collectionView! as! GCollectionView).offsetAccept = true

                        
                        if finished {
                            self.collectionView?.contentOffset = CGPointMake(self.xOffset,0)
                            if !self.toBeExpandedFlag {
                                self.collectionView!.pagingEnabled = true
                                let SpringAnimation = POPSpringAnimation()
                                
                                //animate scrolling to proper cell position
                                SpringAnimation.property = POPAnimatableProperty.propertyWithName(kPOPScrollViewContentOffset) as! POPAnimatableProperty
                                
                                SpringAnimation.toValue = NSValue(CGPoint:CGPointMake(self.tgtXCell,0))
                                SpringAnimation.springBounciness=5;
                                SpringAnimation.springSpeed=4;
                                SpringAnimation.delegate=self
                                
                                self.collectionView!.pop_addAnimation(SpringAnimation, forKey: "contentOffset")
                            }
                            else{
                                self.collectionView!.pagingEnabled = false
                                
                            }
                        } else {
                             self.collectionView?.contentOffset = CGPointMake(self.initxOffset,0)
                        }
                        
                }) as! GTransLayout?
            
            transitioningFlag = true
            let nextLayout = toBeExpandedFlag ? tallLayout : shortLayout
            

            // set proper offset for touched cell

            let moPoint = sender.locationInView(self.collectionView)

            if let cells = self.collectionView?.visibleCells() {
                for  cell in cells{
                    if CGRectContainsPoint(cell.frame, moPoint){
                        self.touchedCell = cell as? UICollectionViewCell
                        self.initXCell = self.touchedCell!.frame.origin.x
                        let indexPath = self.collectionView?.indexPathForCell(touchedCell!)
                        self.tgtXCell = nextLayout.layoutAttributesForItemAtIndexPath(indexPath!).frame.origin.x
                        break
                    }
                }
            }
            
            

        case UIGestureRecognizerState.Changed:
            if !transitioningFlag {//if not transitoning, return
                return
            }
//            println("##changed")
            changedFlag = true  // set flag here

            self.removeAnimation()  //remove on-going animation here

            //update position only when point.y is between initialPoint.y and targety
            if self.toBeExpandedFlag{
                if point.y < initialPanPoint.y {
                    point.y = initialPanPoint.y
                }
                else if point.y > targetY {
                    point.y = targetY
                }
            }
            else{
                if point.y > initialPanPoint.y {
                    point.y = initialPanPoint.y
                }
                else if point.y < targetY {
                    point.y = targetY
                }
            }
            if let tcell = self.touchedCell{
                updateXOffset(point.x, progress: progress)
                updateWithProgress(progress)
            }

        case UIGestureRecognizerState.Ended,UIGestureRecognizerState.Cancelled:

            if !changedFlag {//without this guard, collectionview behaves strangely
                return
            }

            if let layout = self.getTransitionLayout(){

                let success = layout.transitionProgress > 0.5
                
                if !asyncNodeFlag{
                    self.stopGesture()          //gesture during finishInteractiveTransition
                                                //will cause crash
                    if success {
                        self.collectionView?.finishInteractiveTransition()
                        self.toBeExpandedFlag = !self.toBeExpandedFlag
                    }
                    else{
                        self.collectionView?.cancelInteractiveTransition()
                    }
                }
                else{
                    var yToReach : CGFloat
                    if success {
                        yToReach = targetY
                    }
                    else{
                        yToReach = initialPanPoint.y
                    }
                    let durationToFinish = abs(yToReach - point.y) / yVelocity
                    self.xWhenReleased = point.x    //record point.x to calculate contentOffset during final animation
                    self.finishInteractiveTransition(progress, duration: durationToFinish, success:success)
                }
            }
            else{
                self.finishUpInteraction(false)
            }
    
        default:
            break
        }

    }
    
    //calculate proper contentOffset for CollectionView
    //
    func updateXOffset(xpos:CGFloat, progress:CGFloat){
        let xorgForCell = (1-progress)*self.initXCell + progress * self.tgtXCell
        self.xOffset = initxOffset + initialPanPoint.x - xpos  + (xorgForCell - self.initXCell)
    }
    
    func updatePositionData(point:CGPoint,progress:CGFloat){
        let tallHeight = tallLayout.itemSize.height
        let shortHeight = shortLayout.itemSize.height
        
        let itemHeight = (1-progress) * (toBeExpandedFlag ? shortHeight : tallHeight)
            + progress * (toBeExpandedFlag ? tallHeight : shortHeight)
        let hRatio = (tallLayout.itemSize.height - point.y) / itemHeight

        initialPanPoint.y = tallHeight - hRatio * (toBeExpandedFlag ? shortLayout.itemSize.height:tallLayout.itemSize.height)
        targetY = tallHeight - hRatio * (toBeExpandedFlag ? tallLayout.itemSize.height:shortLayout.itemSize.height)
    }
    

    
    func finishInteractiveTransition(progress:CGFloat,duration:CGFloat,success:Bool){
        
            if (success && (progress >= 1.0)) || (!success && (progress <= 0.0)) {
                // no need to animate
                self.finishUpInteraction(success)
            }
            else if self.pop_animationForKey("animation") == nil {
                
                //add end interaction animation
                
                let prop:POPAnimatableProperty = POPAnimatableProperty.propertyWithName("com.goromi.ptrans.progress", initializer: {prop in
                    prop.readBlock = {obj, values in
                        if let layout = self.getTransitionLayout(){
                            values[0] = layout.transitionProgress
                        }
                    }
                    prop.writeBlock = {obj, values in
                        // contentOffset has to be animated accoringly
                        self.updateXOffset(self.xWhenReleased, progress: values[0])
                        self.updateWithProgress(values[0])
                    }
                    prop.threshold = 0.1
                }) as! POPAnimatableProperty
                
                let anim = POPBasicAnimation()
                anim.property = prop
                anim.fromValue = progress
                anim.toValue = success ? 1.0 : 0.0

                anim.completionBlock = { animation, finished in
                    self.finishUpInteraction(success)
                }
                self.pop_addAnimation(anim, forKey: "animation")
            }

    }
    
    func finishUpInteraction(success:Bool){
        if !transitioningFlag {
            return
        }

        if success {
            self.updateWithProgress(1.0)
            //(self.collectionView! as GCollectionView).offsetAccept = false
            self.collectionView?.finishInteractiveTransition()
            transitioningFlag = false
            self.toBeExpandedFlag = !self.toBeExpandedFlag
        }
        else{
            self.updateWithProgress(0.0)
            self.collectionView?.cancelInteractiveTransition()
            transitioningFlag = false
        }
    }

    
    func stopGesture(){
        self.panRecog!.enabled = false
    }
    
    func startGesture(){
        self.panRecog!.enabled = true
    }
    
    func updateWithProgress(progress:CGFloat){
        //collectionViewLayout may be changed between flowLayout and transitionLayout
        //at any time. therefore, this guard is needed
        
        if let layout = getTransitionLayout(){
            //layout.transitionProgress = progress
        
            (layout as! GTransLayout).setProgress(progress, xOffset: xOffset)
        }
    }
    
    func getTransitionLayout()->UICollectionViewTransitionLayout?{
        
        let layout = self.collectionView?.collectionViewLayout
    
        if layout!.isKindOfClass(UICollectionViewTransitionLayout) {
            return layout as? UICollectionViewTransitionLayout
        }
        else{
            return nil
        }
    }
    
    //if true is returned, scrolling and zooming will be messed up
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool{
            return false
    }
    

}

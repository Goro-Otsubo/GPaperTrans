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
    var asyncNodeFlag:Bool          //if true, use GCollectioniViewCell and pop
    var initialPanPoint:CGPoint     // record the point where pan began
    var shortLayout:UICollectionViewFlowLayout  //layout for short height collectionViewCell
    var tallLayout:UICollectionViewFlowLayout   //layout for tall height collectionViewCell
    var toBeExpandedFlag:Bool       //true if transition from short to tall. false if otherwise
    var targetY:CGFloat             //if the touch point moved to this y values, progress should be 1.0
    var panRecog:UIPanGestureRecognizer?
    var transitioningFlag = false   //true from collectioView.startInt.. to finishUpInteraction
    var changedFlag = false         //true if UIGestureRecognizerState.Changed  after interaction began
    
    override init(collectionViewLayout layout: UICollectionViewLayout!) {
        
        self.asyncNodeFlag = true           //default value. will be set by 
                                            //GRootViewController in viewDidLoad
        self.initialPanPoint = CGPointZero
        self.toBeExpandedFlag = true
        self.targetY = 0
        self.shortLayout = UICollectionViewFlowLayout()
        self.tallLayout = UICollectionViewFlowLayout()
        self.panRecog = nil

        super.init(collectionViewLayout: layout)
        
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
        self.collectionView?.backgroundColor = UIColor.clearColor()

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
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as GCollectionViewCell
            cell.setIndex(indexPath.row, size: toBeExpandedFlag ? shortLayout.itemSize : tallLayout.itemSize)
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(synReuseIdentifier, forIndexPath: indexPath) as GSyncViewCell
            cell.setIndex(indexPath.row, size:  toBeExpandedFlag ? shortLayout.itemSize : tallLayout.itemSize)
            return cell
        }
    }


    

    override func collectionView(collectionView: UICollectionView,
        transitionLayoutForOldLayout fromLayout: UICollectionViewLayout,
        newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout
    {
        let ret = UICollectionViewTransitionLayout(currentLayout:fromLayout, nextLayout: toLayout)

        return ret
        
    }
    
    func removeAnimation(){
        
        //completionBlock is executed when animation is removed.
        //therefore, make completionBlock nil before removal
        
        let anim: POPBasicAnimation? = self.pop_animationForKey("animation") as POPBasicAnimation?

        if anim != nil{
            anim!.completionBlock = nil
        }
        self.pop_removeAllAnimations()
    }

    // MARK: Gesture recognizer related
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if(gestureRecognizer === self.panRecog) {
            let panRecog = gestureRecognizer as UIPanGestureRecognizer
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
        
        let point = sender.locationInView(sender.view)
        let velocity = sender.velocityInView(sender.view)
        
        //limit the range of velocity so that animation will not stop when verlocity is 0
        
        let yVelocity = CGFloat(max(min(abs(velocity.y),80.0),20.0))
        
        let progress = max(min(abs(point.y - initialPanPoint.y)/abs(targetY - initialPanPoint.y),1.0),0.0)
        
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

            self.collectionView?.startInteractiveTransitionToCollectionViewLayout(
                    toBeExpandedFlag ? tallLayout : shortLayout,
                    completion: { completed, finished in
                        if !self.asyncNodeFlag {
                            self.postInteractionFinished()
                        }
                })
            transitioningFlag = true

        case UIGestureRecognizerState.Changed:
            if !transitioningFlag {//if not transitoning, return
                return
            }
//            println("##changed")
            changedFlag = true  // set flag here

            self.removeAnimation()  //remove on-going animation here
            
            //update position only when point.y is between initialPoint.y and targety
            if (point.y - initialPanPoint.y) * (point.y - targetY) <= 0 {
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
    
    func updatePositionData(point:CGPoint,progress:CGFloat){
        let tallHeight = tallLayout.itemSize.height
        let shortHeight = shortLayout.itemSize.height
        
        let itemHeight = (1-progress) * (toBeExpandedFlag ? shortHeight : tallHeight)
            + progress * (toBeExpandedFlag ? tallHeight : shortHeight)
        let hRatio = (tallLayout.itemSize.height - point.y) / itemHeight

        initialPanPoint.y = tallHeight - hRatio * (toBeExpandedFlag ? shortLayout.itemSize.height:tallLayout.itemSize.height)
        targetY = tallHeight - hRatio * (toBeExpandedFlag ? tallLayout.itemSize.height:shortLayout.itemSize.height)
    }
    
    func postInteractionFinished(){
        if !self.asyncNodeFlag {
            self.startGesture()
        }
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
                        //println("value = \(values[0])")
                        self.updateWithProgress(values[0])
                    }
                    prop.threshold = 0.1
                }) as POPAnimatableProperty
                
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
            layout.transitionProgress = progress
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
    
    //to enable user to interact both vertically and horizontally, may need to
    //return yes here. but at this point, it just messes up.
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool{
            return false
    }
}

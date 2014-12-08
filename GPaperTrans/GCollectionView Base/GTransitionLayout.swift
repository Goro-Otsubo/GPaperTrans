//
//  GTransitionLayout.swift
//  GPaperTrans
//
//  Created by demodev on 2014/11/14.
//  Copyright (c) 2014年 demodev. All rights reserved.
//

import UIKit

class GTransitionLayout: UICollectionViewTransitionLayout {
    
    let kOffsetH = "kOffsetH"
    let kOffsetV = "kOffsetV"
    
    var offset:UIOffset{
        set(newOffset){
            // store the floating-point values with out meaningful keys for our transition layout object
            self.updateValue(newOffset.horizontal, forAnimatedKey: kOffsetH)
            self.updateValue(newOffset.vertical, forAnimatedKey:kOffsetV)
            self.offset = newOffset;
        }
        get{
            return self.offset
        }
    }
    var progress:CGFloat {
        set(newValue){
            self.progress = newValue
            let offsetH = self.valueForAnimatedKey(kOffsetH)
            let offsetV = self.valueForAnimatedKey(kOffsetV)
            self.offset = UIOffsetMake(offsetH, offsetV);
        }
        get{
            return self.progress
        }
    }
    var itemSize:CGSize
    
    
    required override init(){
        //offset = UIOffsetZero
        itemSize = CGSizeZero
        
        super.init()
    }
    
    required override init(currentLayout: UICollectionViewLayout, nextLayout newLayout: UICollectionViewLayout) {
        itemSize = CGSizeZero
        super.init(currentLayout: currentLayout, nextLayout: newLayout)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var attributes = super.layoutAttributesForElementsInRect(rect) as [UICollectionViewLayoutAttributes]
        
        for currentAttribute:UICollectionViewLayoutAttributes in attributes{
            let currentCenter = currentAttribute.center
            let updatedCenter = CGPointMake(currentCenter.x, currentCenter.y + self.offset.vertical)
            currentAttribute.center = updatedCenter
        }
        
        return attributes;
    }
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        // returns the layout attributes for the item at the specified index path
        var attributes = super.layoutAttributesForItemAtIndexPath( indexPath)
        
        let currentCenter = attributes.center;
        let updatedCenter = CGPointMake(currentCenter.x + self.offset.horizontal, currentCenter.y + self.offset.vertical)
        attributes.center = updatedCenter;
        return attributes;
    }
}

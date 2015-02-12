//
//  GCollectionView.swift
//  GPaperTrans
//
//  Created by 大坪五郎 on 2015/02/03.
//  Copyright (c) 2015年 demodev. All rights reserved.
//

import UIKit

//subclass of UICollectionView
//which has "guard"to prevent from unexpected contentOffset change

class GCollectionView: UICollectionView{
    var offsetAccept:Bool
    


    required override init(frame:CGRect,collectionViewLayout:UICollectionViewLayout){
        offsetAccept = true
        super.init(frame:frame, collectionViewLayout:collectionViewLayout)
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func setContentOffset(contentOffset: CGPoint) {

        if self.offsetAccept{
            super.contentOffset = contentOffset
        }
    }
    
    override func finishInteractiveTransition() {

        self.offsetAccept = false
        super.finishInteractiveTransition()
//        self.offsetAccept = true //will be restored in viewController finish block
    }
    

}

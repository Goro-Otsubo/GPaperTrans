//
//  GTransLayout.swift
//  GPaperTrans
//
//  Created by 大坪五郎 on 2015/01/21.
//  Copyright (c) 2015年 demodev. All rights reserved.
//

import UIKit

//Custom Transition layout
//

class GTransLayout: UICollectionViewTransitionLayout {

    required override init(currentLayout:UICollectionViewLayout,nextLayout:UICollectionViewLayout){
        super.init(currentLayout: currentLayout, nextLayout: nextLayout)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("cant instantiate this way")
    }
    
    func setProgress(progress:CGFloat, xOffset:CGFloat){

        (self.collectionView! as GCollectionView).offsetAccept = false
        super.transitionProgress = progress     //contentOffset will be set to 0.0. therefore set "guard"
        (self.collectionView! as GCollectionView).offsetAccept = true
        
        var prefOffset = self.collectionView!.contentOffset
        prefOffset.x = xOffset
        self.collectionView?.contentOffset = prefOffset //specified contentOffset will be set

    }
    
}

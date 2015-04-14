//
//  GChoiceViewController.swift
//  GPaperTrans
//
//  Created by Goro Otsubo on 2014/11/28.
//  Copyright (c) 2014年 Goro Otsubo. All rights reserved.
//

import UIKit

// Controller for first screen
// Just launch GRootViewController with sync/async parameter
// sync:UIVIew + finishInteractiveTransation
// async: AsyncNode + Pop animation

class GChoiceViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = CGRectGetWidth(self.view.frame)
        let height = CGRectGetHeight(self.view.frame)
        
        let aSyncButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        aSyncButton.frame = CGRectMake(0,0,width,height/2)
        aSyncButton.setTitle("Responsive", forState: UIControlState.Normal)
        aSyncButton.backgroundColor = UIColor.greenColor()
        aSyncButton.titleLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        aSyncButton.addTarget(self, action: "showAsyncVertical:", forControlEvents:.TouchUpInside)
        
        self.view.addSubview(aSyncButton)
        
        let syncButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        syncButton.frame = CGRectMake(0,height/2,width,height/2)
        syncButton.setTitle("Standard", forState: UIControlState.Normal)
        syncButton.backgroundColor = UIColor.yellowColor()
        syncButton.titleLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        syncButton.addTarget(self, action: "showSyncVertical:", forControlEvents:.TouchUpInside)
        
        self.view.addSubview(syncButton)


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Call backs to present viewControllers


    func showSyncVertical(sender: AnyObject){
        let viewController = GRootViewController(nibName: nil, bundle: nil)
        
        viewController.asyncFlag = false    //this is sync view
        
        viewController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        self.presentViewController(viewController, animated: true, completion: nil)
    }
 
    func showAsyncVertical(sender: AnyObject){
        let viewController = GRootViewController(nibName: nil, bundle: nil)
        
        viewController.asyncFlag = true // this is async view
        
        viewController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        self.presentViewController(viewController, animated: true, completion: nil)
    }

}

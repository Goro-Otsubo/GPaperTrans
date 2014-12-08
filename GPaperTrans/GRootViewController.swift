//
//  GRootViewController.swift
//  GPaperTrans
//
//  Created by Goro Otsubo on 2014/11/14.
//  Copyright (c) 2014 Goro Otsubo. All rights reserved.
//

import UIKit

// Controller for top basement view
// show top picture

class GRootViewController: UIViewController {

    var imageNode:ASImageNode?                      // image view for top half
    var colViewCtrl:GCollectionViewController? // collectionViewController for bottom half view
    
    var asyncFlag:Bool = true

    
    required  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.imageNode = nil
        self.colViewCtrl = nil
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()

        let viewHeight = CGRectGetHeight(self.view.frame)
        let viewWidth = CGRectGetWidth(self.view.frame)
        let cellSizeRatio:CGFloat = 0.5
        let cellHeight = viewHeight * cellSizeRatio     //height of cell
        
        self.imageNode = ASImageNode()                  // image node for top half
        imageNode!.frame = CGRectMake(0,0,viewWidth,viewHeight-cellHeight)
        imageNode?.backgroundColor = UIColor.darkGrayColor()
        self.fetchImage(viewWidth, y:viewHeight-cellHeight)
        self.view.addSubview(imageNode!.view)
        
        let backLabel = UILabel(frame: CGRectMake(0,0,150,40))
        backLabel.textColor = UIColor.whiteColor()
        backLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        backLabel.text = "Go Back"
        self.view.addSubview(backLabel)
        
        let tapRecog  = UITapGestureRecognizer()
        tapRecog.addTarget(self, action: "tapped:")
        self.view.addGestureRecognizer(tapRecog)
        
        let gradLayer = CAGradientLayer()
        
        gradLayer.frame = imageNode!.frame;
        gradLayer.colors = [
            UIColor(white:0.0 , alpha: 0.4).CGColor,
            UIColor(white:0.0 , alpha: 0.0).CGColor,
            UIColor(white:0.0 , alpha: 0.0).CGColor,
            UIColor(white:0.0, alpha: 0.4).CGColor,
            UIColor(white:0.0, alpha: 0.6).CGColor
        ]
        
        gradLayer.startPoint = CGPointMake(0.5,0);
        gradLayer.endPoint = CGPointMake(0.5,1.0);
        gradLayer.locations = [0.0,0.2,0.93,0.98,1.0]
        
        imageNode!.layer.addSublayer(gradLayer)
        
        
        let shortLayout = UICollectionViewFlowLayout()
        shortLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal

        shortLayout.itemSize = CGSizeMake(viewWidth*cellSizeRatio,cellHeight)
        shortLayout.sectionInset = UIEdgeInsetsMake(viewHeight - cellHeight, 0, 0, 0)
        shortLayout.minimumInteritemSpacing = 0
        shortLayout.minimumLineSpacing = 3
        
        let tallLayout = UICollectionViewFlowLayout()
        tallLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        tallLayout.itemSize = CGSizeMake(viewWidth,viewHeight)
        tallLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tallLayout.minimumInteritemSpacing = 0
        tallLayout.minimumLineSpacing = 3

        self.colViewCtrl = GCollectionViewController(collectionViewLayout: shortLayout)
        
        colViewCtrl?.asyncNodeFlag = asyncFlag
        
        colViewCtrl!.view.frame = self.view.frame
        colViewCtrl!.tallLayout = tallLayout
        colViewCtrl!.shortLayout = shortLayout
        self.view.addSubview(colViewCtrl!.view)



    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    // MARK: Just for Demo
    
    //fetch image and display in upper half part of screen
    
    func fetchImage(x:CGFloat, y:CGFloat){
        let url = NSURL(string:"http://lorempixel.com/\(Int(x))/\(Int(y))/")
        
        SDWebImageDownloader.sharedDownloader().downloadImageWithURL(url,
            options: SDWebImageDownloaderOptions.IgnoreCachedResponse,
            progress: nil,
            completed: {[weak self] (image, data, error, finished) in
                if let wSelf = self {
                    // do what you want with the image/self
                    if let imageData = image {
                        if(wSelf.imageNode!.nodeLoaded){
                            
                            dispatch_sync(dispatch_get_main_queue()) {
                                // once the node's view is loaded, the node should only be used on the main thread
                                wSelf.imageNode!.image = image
                            }
                        }
                        else{
                            wSelf.imageNode!.image = image
                        }
                    }
                }
        })
    }
    
    // call back function to close this controller
    
    func tapped(sender:UITapGestureRecognizer){
        let tappedPos = sender.locationInView(sender.view)
        if CGRectContainsPoint(CGRectMake(0,0,150,100), tappedPos) {
            dismissViewControllerAnimated(true, completion: nil)

        }
    }
}

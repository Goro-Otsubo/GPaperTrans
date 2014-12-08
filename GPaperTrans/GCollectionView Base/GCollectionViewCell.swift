//
//  GCollectionViewCell.swift
//  GPaperTrans
//
//  Created by Goro Otsubo on 2014/11/14.
//  Copyright (c) 2014 Goro Otsubo. All rights reserved.
//

import UIKit

//UICollectionViewCell with ASImageNode
//other than imageView, same as GSyncViewCell


class GCollectionViewCell: UICollectionViewCell {
    var imageNode:ASImageNode
    var indexData:Int
    var cellSize:CGSize
    

    
    required override init(frame: CGRect) {
        self.imageNode = ASImageNode()
        self.indexData = -1
        cellSize = CGSizeZero
        super.init(frame: frame)
        self.imageNode.backgroundColor = UIColor.purpleColor()
        self.contentView.backgroundColor = UIColor.redColor()
        self.contentView.addSubview(imageNode.view)
        self.layer.cornerRadius = 2
        self.clipsToBounds = true
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    func setIndex(index:Int, size:CGSize)->GCollectionViewCell{
        self.indexData = index
        self.cellSize = size
        self.fetchImage()
        self.layout()
        return self
    }
    
    
    func fetchImage(){
        let url = NSURL(string:"http://placekitten.com/g/\(indexData+200)/\(indexData+200)")
        
        SDWebImageDownloader.sharedDownloader().downloadImageWithURL(url,
            options: SDWebImageDownloaderOptions.IgnoreCachedResponse,
            progress: nil,
            completed: {[weak self] (image, data, error, finished) in
                if let wSelf = self {
                    // do what you want with the image/self
                    if let imageData = image {
                        if(wSelf.imageNode.nodeLoaded){
                            
                            dispatch_sync(dispatch_get_main_queue()) {
                                // once the node's view is loaded, the node should only be used on the main thread
                                wSelf.imageNode.image = image
                            }
                        }
                        else{
                            wSelf.imageNode.image = image
                        }
                    }
                }
        })
    }
    
    func calculateSizeThatFits(size:CGSize)->CGSize{
        return cellSize
    }
    
    func  layout(){
        let calculatedSize = self.frame.size
        imageNode.frame = CGRectMake(0,0,calculatedSize.width,calculatedSize.height)
    }
    
    override func layoutSubviews() {
        self.layout()
    }
    
    override func prepareForReuse() {
        imageNode.image = nil
        super.prepareForReuse()
    }
}

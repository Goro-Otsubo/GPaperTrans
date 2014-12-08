//
//  GSyncViewCell.swift
//  GPaperTrans
//
//  Created by Goro Otsubo on 2014/11/28.
//  Copyright (c) 2014年 Goro Otsubo. All rights reserved.
//

import UIKit

//UICollectionViewCell with UIImageView
//other than imageView, same as GCollectionViewCell

class GSyncViewCell: UICollectionViewCell {
    var imageNode:UIImageView
    var indexData:Int
    var cellSize:CGSize = CGSizeZero
    
    required override init(frame: CGRect) {
        self.imageNode = UIImageView()
        self.indexData = -1

        super.init(frame: frame)
        self.imageNode.backgroundColor = UIColor.purpleColor()
        self.imageNode.contentMode = UIViewContentMode.ScaleAspectFill
        self.contentView.backgroundColor = UIColor.redColor()
        self.contentView.addSubview(imageNode)
        self.layer.cornerRadius = 2
        self.clipsToBounds = true
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    func setIndex(index:Int, size:CGSize)->GSyncViewCell{
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
                        wSelf.imageNode.image = image
                    }
                }
        })
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

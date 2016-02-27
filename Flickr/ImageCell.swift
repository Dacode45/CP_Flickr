//
//  ImageCell.swift
//  Flickr
//
//  Created by Labuser on 2/26/16.
//  Copyright © 2016 TeamKickAss. All rights reserved.
//

import UIKit
import Parse 
class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
   var image : PFObject?{
        didSet{
            let imageFile = image?.objectForKey("media") as! PFFile
            imageFile.getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
                if(error == nil){
                    self.imageView.image = UIImage(data: data!)
                    self.imageView.layer.cornerRadius = 30
                    self.imageView.layer.masksToBounds = true
                    self.imageView.layer.borderColor = UIColor.whiteColor().CGColor
                    self.imageView.layer.borderWidth = 1
                    
                }
            }
        }
    }
    
    
    func resize(image: UIImage, newSize: CGSize) -> UIImage {
        let resizeImageView = UIImageView(frame: CGRectMake(0, 0, newSize.width, newSize.height))
        resizeImageView.contentMode = UIViewContentMode.ScaleAspectFill
        resizeImageView.image = image
        
        UIGraphicsBeginImageContext(resizeImageView.frame.size)
        resizeImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

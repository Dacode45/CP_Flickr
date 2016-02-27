//
//  UserComment.swift
//  Flickr
//
//  Created by Labuser on 2/26/16.
//  Copyright © 2016 TeamKickAss. All rights reserved.
//

import UIKit
import Parse
class UserComment: NSObject {
    /**
     * Other methods
     */
     
     
     /**
     Method to post user media to Parse by uploading image file
     
     - parameter image: Image that the user wants upload to parse
     - parameter caption: Caption text input by the user
     - parameter completion: Block to be executed after save operation is complete
     */
    class func postUserComment(message: String, image: PFObject, withCompletion completion: PFBooleanResultBlock?) -> PFObject{
        // Create Parse object PFObject
        let media = PFObject(className: "UserComment")
        
        // Add relevant fields to the object
        media["comment"] = message // PFFile column type
        media["author"] = PFUser.currentUser() // Pointer column type that points to PFUser
        media["image"] = image.objectId
        media["likesCount"] = 0
        media["commentsCount"] = 0
        
        // Save object (following function will save the object in Parse asynchronously)
        media.saveInBackgroundWithBlock(completion)
        return media
    }
    
    class func getCommentsOfImage(image: PFObject, withCompletion completion: PFQueryArrayResultBlock){
        let query = PFQuery(className: "UserComment")
        query.orderByDescending("createdAt")
        query.whereKey("image", equalTo: image.objectId!)
        query.limit = 20
        query.findObjectsInBackgroundWithBlock(completion)
    }

}

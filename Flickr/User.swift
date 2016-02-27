//
//  User.swift
//  Flickr
//
//  Created by Labuser on 2/26/16.
//  Copyright © 2016 TeamKickAss. All rights reserved.
//

import UIKit

var _currentUser: User?
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"
class User: NSObject {
    var id: Int?
    var name: String?
    var profileImageURL: String?
    
}

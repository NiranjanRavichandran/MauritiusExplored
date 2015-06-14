//
//  CategoryDetails.swift
//  MauritiusExplored
//
//  Created by Niranjan Ravichandran on 11/06/15.
//  Copyright (c) 2015 Adavers. All rights reserved.
//

import Foundation

class CategoryDetails: NSObject {
    
    var objectId: String
    var name: String
    var parentId: String
    var level: Int
    
    init(categoryObject: AnyObject){
        
        objectId = categoryObject.objectId!!
        name = categoryObject["CategoryName"] as! String
        parentId = categoryObject["ParentId"] as! String
        level = categoryObject["Level"] as! Int
    }
    
}
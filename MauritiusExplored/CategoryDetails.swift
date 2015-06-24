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
    var lattitude = "-20.116667"
    var longitude = "57.583333"
    var webLink = String()
    
    init(categoryObject: AnyObject){
        
        objectId = categoryObject.objectId!!
        name = categoryObject["CategoryName"] as! String
        parentId = categoryObject["ParentId"] as! String
        level = categoryObject["Level"] as! Int
        if let lat = categoryObject["lattitude"] as? String{
            lattitude = lat
        }
        if let long =  categoryObject["longitude"] as? String{
            longitude = long
        }
        if let link = categoryObject["webLink"] as? String{
            webLink = link
        }
    }
    
}
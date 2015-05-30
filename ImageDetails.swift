//
//  ImageDetails.swift
//  MauritiusExplored
//
//  Created by Niranjan Ravichandran on 28/05/15.
//  Copyright (c) 2015 Adavers. All rights reserved.
//

import Foundation
import Parse

struct PhotoDetails {
    
    var thumbnail: PFFile
    var largeImage: PFFile
    var imageDesc: String
    var linkId: String
    var superParentId: String
    var imageId: String
    
    init(imageObjects: AnyObject){
        
        thumbnail = imageObjects["thumbnail"] as! PFFile
        largeImage = imageObjects["imageFile"] as! PFFile
        linkId = imageObjects["LinkId"] as! String
        superParentId = imageObjects["SuperParentId"] as! String
        imageDesc = imageObjects["Description"] as! String
        imageId = imageObjects.objectId!!
        
    }
}
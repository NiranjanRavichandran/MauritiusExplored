//
//  Reachability.swift
//  MauritiusExplored
//
//  Created by Niranjan Ravichandran on 19/06/15.
//  Copyright (c) 2015 Adavers. All rights reserved.
//

import Foundation


class Reachability {
    
    class func reachabilityTest() -> Bool{
        
        var status: Bool = false
        let url = NSURL(string: "htttp://googel.com")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "HEAD"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        
        var response: NSURLResponse?
        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: nil) as NSData?
        
        if let httpResponse = response as? NSHTTPURLResponse {
            if httpResponse.statusCode == 200{
                
                status = true
            }
        }
        
        return status
    }
}
//
//  ActivityIndicator.swift
//  MauritiusExplored
//
//  Created by Niranjan Ravichandran on 18/05/15.
//  Copyright (c) 2015 Adavers. All rights reserved.
//

import UIKit

class ActivityIndicator {
    
    var activityIndicator: UIActivityIndicatorView?
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
    var blurredView: UIVisualEffectView = UIVisualEffectView()
    
    func startIndicator(activityStyle: UIActivityIndicatorViewStyle){
        
        blurredView = UIVisualEffectView(effect: blurEffect)
        blurredView.frame = UIScreen.mainScreen().bounds
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator!.center = blurredView.center
        activityIndicator!.hidesWhenStopped = true
        activityIndicator!.activityIndicatorViewStyle = activityStyle
        
        
        blurredView.addSubview(activityIndicator!)
        activityIndicator!.startAnimating()
        //UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
    }
    
    func stopIndicator(){
        activityIndicator?.stopAnimating()
        //UIApplication.sharedApplication().endIgnoringInteractionEvents()
        blurredView.removeFromSuperview()
    }

}

//
//  BadConnectionView.swift
//  MauritiusExplored
//
//  Created by Niranjan Ravichandran on 19/06/15.
//  Copyright (c) 2015 Adavers. All rights reserved.
//

import UIKit

class BadConnectionView: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func retryConnection(sender: AnyObject) {
        
        var parent = view.superview
        view.removeFromSuperview()
        self.removeFromParentViewController()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

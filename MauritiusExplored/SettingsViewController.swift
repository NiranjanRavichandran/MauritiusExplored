//
//  SettingsViewController.swift
//  MauritiusExplored
//
//  Created by Niranjan Ravichandran on 05/06/15.
//  Copyright (c) 2015 Adavers. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet var menuButton: UIButton!
    @IBOutlet var backGroundImage: UIImageView!
    @IBOutlet var adaversLink: UILabel!
    @IBOutlet var firstName: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var phone: UITextField!
    @IBOutlet var editButtons: [UIButton]!
    
    var editEnabled = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backGroundImage.image = UIImage(named: "Settings-Bg.jpg")
        // Do any additional setup after loading the view.
        if self.revealViewController() != nil{
            
            menuButton.addTarget(self.revealViewController(), action: "revealToggle:", forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    @IBAction func editInfo(sender: AnyObject) {
        
        if !editEnabled{
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                self.editButtons[0].alpha = 1
                self.editButtons[1].alpha = 1
                self.editEnabled = true
                
            })
        }else{
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                self.editButtons[0].alpha = 0
                self.editButtons[1].alpha = 0
                self.editEnabled = false
            })
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func shareOption(sender: AnyObject) {
        
        let textToShare = "Check out Mauritius Explored in App Store & Play Store! A cool app for your vacation in Mauritius"
        let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        
        //New Excluded Activities Code
        activityVC.excludedActivityTypes = [UIActivityTypeAirDrop]
        
        self.presentViewController(activityVC, animated: true, completion: nil)
    }

    
    @IBAction func saveInformation(sender: AnyObject) {
        
        
    }
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        let touch: UITouch = (event.allTouches()?.first as? UITouch)!
        if CGRectContainsPoint(adaversLink.frame, touch.locationInView(view)){
            
            UIApplication.sharedApplication().openURL(NSURL(string: "http://adavers.com")!)
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
}

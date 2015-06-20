//
//  SettingsViewController.swift
//  MauritiusExplored
//
//  Created by Niranjan Ravichandran on 05/06/15.
//  Copyright (c) 2015 Adavers. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var menuButton: UIButton!
    @IBOutlet var backGroundImage: UIImageView!
    @IBOutlet var adaversLink: UILabel!
    @IBOutlet var firstName: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var phone: UITextField!
    @IBOutlet var editButtons: [UIButton]!
    
    @IBOutlet var textFields: [TextField]!
    var editEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backGroundImage.image = UIImage(named: "Settings-Bg.jpg")
        // Do any additional setup after loading the view.
        if self.revealViewController() != nil{
            
            menuButton.addTarget(self.revealViewController(), action: "revealToggle:", forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        resetInfo(self)
        
        for item in textFields{
            item.delegate = self
            item.userInteractionEnabled = false
        }
    }
    
    @IBAction func editInfo(sender: AnyObject) {
        
        if !editEnabled{
            
            for item in self.textFields{
                item.userInteractionEnabled = true
            }
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                for item in self.editButtons{
                    item.alpha = 1
                }
                self.editEnabled = true
                
            })
        }else{
            for item in self.textFields{
                item.userInteractionEnabled = false
            }
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                for item in self.editButtons{
                    item.alpha = 0
                }
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
    
    @IBAction func resetInfo(sender: AnyObject) {
        var currentUser = PFUser.currentUser()
        self.email.text = currentUser?.email
        if let phone = currentUser?.objectForKey("Phone") as? String{
            self.phone.text = phone
        }
        if let name = currentUser?.objectForKey("Name") as? String{
            self.firstName.text = name
        }
    }
    
    @IBAction func saveInformation(sender: AnyObject) {
        var error: String?
        var title: String?
        var currentUser = PFUser.currentUser()
        for item in textFields{
            if item.text == ""{
                title = "Oops!"
                error = "Please enter all fields."
                displayAlert(title!, error: error!)
            }else{
                
                currentUser?.email = email.text
                currentUser?.setValue(firstName.text, forKey: "Name")
                currentUser?.setValue(phone.text, forKey: "Phone")
                currentUser?.saveInBackgroundWithBlock({ (success, updateError) -> Void in
                    
                    if updateError == nil{
                        title = "Vola"
                        error = "Your info has be updated!"
                        self.displayAlert(title!, error: error!)
                        //Hiding and disabling textfields....
                        for item in self.textFields{
                            item.userInteractionEnabled = false
                        }
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            
                            for item in self.editButtons{
                                item.alpha = 0
                            }
                            self.editEnabled = false
                        })
                        
                    }else{
                        if updateError!.code == 100{
                            title = "Oops!"
                            error = "Please check your internet connection. Re-attempting to save."
                            self.displayAlert(title!, error: error!)
                        }
                    }
                })
                
            }
        }
    }
    
    func displayAlert(title: String, error: String){
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        let touch: UITouch = (event.allTouches()?.first as? UITouch)!
        if CGRectContainsPoint(adaversLink.frame, touch.locationInView(view)){
            
            UIApplication.sharedApplication().openURL(NSURL(string: "http://adavers.com")!)
        }
        
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
}

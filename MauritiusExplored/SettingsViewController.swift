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
    let alert = SCLAlertView()
    let errorAlert = SCLAlertView()
    
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
        //Hiding textfields...
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
    
    @IBAction func saveInformation(sender: AnyObject) {
        var error: String?
        var title: String?
        var currentUser = PFUser.currentUser()
        
        if email.text == "" || email.text == nil{
            title = "Oops!"
            error = "Please enter your email ID"
            errorAlert.showError(title!, subTitle: error!, closeButtonTitle: "Okay", duration: 0, colorStyle: 0xC1272D, colorTextButton: 0xFFFFFF)
        }else{
            if isValidEmail(email.text){
                currentUser?.email = email.text
                currentUser?.setValue(firstName.text, forKey: "Name")
                currentUser?.setValue(phone.text, forKey: "Phone")
                currentUser?.saveInBackgroundWithBlock({ (success, updateError) -> Void in
                    
                    if updateError == nil{
                        title = "Success!"
                        error = "Your info has be updated!"
                        self.alert.showSuccess(title!, subTitle: error!, closeButtonTitle: "Okay", duration: 0, colorStyle: 0x22B573, colorTextButton: 0xFFFFFF)
                        defaults.setObject(self.email.text, forKey: "UserMail")
                        
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
                            self.errorAlert.showError(title!, subTitle: error!, closeButtonTitle: "Done", duration: 0, colorStyle: 0xC1272D, colorTextButton: 0xFFFFFF)
                        }
                    }
                })
            }else{
                
                title = "Oops!"
                error = "Please enter valid email ID"
                errorAlert.showError(title!, subTitle: error!, closeButtonTitle: "Ok", duration: 0, colorStyle: 0xC1272D, colorTextButton: 0xFFFFFF)
            }
        }
    }
    
    @IBAction func displayAbout(sender: AnyObject) {
        
        let aboutAlert = SCLAlertView()
        aboutAlert.showNotice("Version 1.0", subTitle: "Mauritius is the Best Holiday destination. Discover more than the island. Where to go? Ask us, Explore the hidden gem!", closeButtonTitle: "Close", duration: 0, colorStyle: 0xFF6654, colorTextButton: 0xFFFFFF)
    }
    
    func displayAlert(title: String, error: String){
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
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

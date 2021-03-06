//
//  SignUpViewController.swift
//  MauritiusExplored
//
//  Created by Niranjan Ravichandran on 25/04/15.
//  Copyright (c) 2015 Adavers. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, UITextFieldDelegate {


    @IBOutlet weak var email: UITextField!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
    var blurredView: UIVisualEffectView = UIVisualEffectView()
    let defaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        email.delegate = self
        //email.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        

//        let paddingView = UIView(frame: CGRectMake(0, 0, 60, self.email.frame.height))
//        email.leftView = paddingView
//        email.leftViewMode = UITextFieldViewMode.Always
        // Do any additional setup after loading the view.
//        var backgroundView = UIImageView(frame: UIScreen.mainScreen().bounds)
//        backgroundView.image = UIImage(named: "GirlBg")
        
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func nextAction(sender: AnyObject) {
        
        self.view.endEditing(true)
        var error = ""
        
        if !isValidEmail(email.text){
            error = "Please enter a valid email Id"
        }else{
            
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            let defaults = NSUserDefaults.standardUserDefaults()
            
            
            var user = PFUser()
            user.username = email.text
            user.email = email.text
            user.password = "password"
            
            user.signUpInBackgroundWithBlock({ (success: Bool, signUpError: NSError?) -> Void in
                if (success == true) {
                    
                    println("Sign up Success!")
                    defaults.setObject(self.email.text, forKey: "UserMail")
                    self.performSegueWithIdentifier("login", sender: self)
                    
                }else{
                    if signUpError?.code == 202{
                        
//                        var signUpAlert = UIAlertController(title: "Email already exists!", message: "Please use a different email or continue with the same email", preferredStyle: .Alert)
//                        signUpAlert.addAction(UIAlertAction(title: "Continue", style: .Default, handler: { action in
//                            
//                            
//                        }))
                        
                        let alert = SCLAlertView()
                        alert.addButton("Continue", action: { () -> Void in
                            println("Lets begin!")
                            defaults.setObject(self.email.text, forKey: "UserMail")
                            
                            // Loading favourites for existing email
                            let getFavQuery = PFQuery(className: "Favourites")
                            getFavQuery.whereKey("UserId", equalTo: self.email.text)
                            getFavQuery.getFirstObjectInBackgroundWithBlock({ (favObject, error) -> Void in
                                
                                if error == nil{
                                    
                                    let favs = favObject?.valueForKey("ImageId") as! [String]
                                    self.defaults.setObject(favs, forKey: "Favourites")
                                }
                            })
                            
                            self.performSegueWithIdentifier("login", sender: self)
                        })
                        alert.showNotice("Email already exists!", subTitle: "Please use a different email or click continue to proceed with same email.", closeButtonTitle: "Cancel", duration: 0, colorStyle: 0x727375, colorTextButton: 0xFFFFFF)
//                        signUpAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
//                        self.presentViewController(signUpAlert, animated: true, completion: nil)
                    }else if signUpError?.code == 100{
                        
                        self.displayErrorView()
                    }
                }
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            })
        }
        
        if error != ""{
            //displayAlert("Oops!", error: error)
            SCLAlertView().showError("Oops!", subTitle:error, closeButtonTitle:"OK")
        }
    }
    
    func displayErrorView(){
        
        let controller: BadConnectionView = self.storyboard?.instantiateViewControllerWithIdentifier("NoConnectionView") as! BadConnectionView
        self.addChildViewController(controller)
        controller.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        self.view.addSubview(controller.view)
        self.view.center = (self.view.superview?.center)!
        controller.didMoveToParentViewController(self)
    }

//    func displayAlert(title: String, error: String){
//        
//        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
//        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
//        
//        self.presentViewController(alert, animated: true, completion: nil)
//    }
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        
        return false
    }
    
}

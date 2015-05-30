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
        
        if email.text == "" {
            error = "Please enter your email"
        }else{
            
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(email.text, forKey: "UserMail")
            
            var user = PFUser()
            user.username = email.text
            user.email = email.text
            user.password = "password"
            
            user.signUpInBackgroundWithBlock({ (success: Bool, signUpError: NSError?) -> Void in
                if (success == true) {
                    println("Sign up Success!")
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.performSegueWithIdentifier("toNextView", sender: self)
                }else{
                    println(signUpError)
                }
            })
        }
        
        if error != ""{
            displayAlert("Oops!", error: error)
        }
    }
    
    func displayAlert(title: String, error: String){
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
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

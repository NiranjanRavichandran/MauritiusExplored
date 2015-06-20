//
//  ViewController.swift
//  MauritiusExplored
//
//  Created by Niranjan Ravichandran on 25/04/15.
//  Copyright (c) 2015 Adavers. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var contactNumber: UITextField!
    let defaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.contactNumber.delegate = self
        PFUser.logInWithUsernameInBackground(defaults.objectForKey("UserMail") as! String, password:"password") {
            (user: PFUser?, loginError: NSError?) -> Void in
            if user != nil {
                // Do stuff after successful login.
                println("Login Success!")
                
            } else {
                // The login failed. Check error to see why.
                println(loginError)
            }
        }
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    @IBAction func proceedAction(sender: AnyObject) {
        
        self.view.endEditing(true)
        var error = ""
        
        if contactNumber.text == "" {
            
            error = "Please enter your mobile number"
        }else{
        
            var currentUser = PFUser.currentUser()
            currentUser?.setValue(contactNumber.text, forKey: "Phone")
            currentUser?.saveInBackgroundWithBlock({ (success, updateError) -> Void in
                
                if updateError == nil {
                    println("Saved Contact info")
                    PFUser.logInWithUsername(self.defaults.objectForKey("UserMail") as! String, password: "password")
                }else{
                    
                    if updateError?.code == 100{
                        error = "Please check you internet connection and try again!"
                    }
                }
            })
        self.performSegueWithIdentifier("LoginPage", sender: self)
            
        }
        if error != ""{
            displayAlert("Oops!", error: error)
        }
    }
    
    func displayAlert(title: String, error: String){
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        
        textField.resignFirstResponder()
        return true
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let getFavQuery = PFQuery(className: "Favourites")
        getFavQuery.whereKey("UserId", equalTo: defaults.valueForKey("UserMail") as! String)
        getFavQuery.getFirstObjectInBackgroundWithBlock({ (favObject, error) -> Void in
            
            if error == nil{
                
                let favs = favObject?.valueForKey("ImageId") as! [String]
                self.defaults.setObject(favs, forKey: "Favourites")
            }
        })
    }

    override func shouldAutorotate() -> Bool {
        
        return false
    }
}


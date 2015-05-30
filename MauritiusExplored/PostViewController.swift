//
//  PostViewController.swift
//  MauritiusExplored
//
//  Created by Niranjan Ravichandran on 29/04/15.
//  Copyright (c) 2015 Adavers. All rights reserved.
//

import UIKit
import Parse
import MapKit

extension UIImage{
    var highestQualityJPEGNSData:NSData { return UIImageJPEGRepresentation(self, 1.0) }
    var highQualityJPEGNSData:NSData    { return UIImageJPEGRepresentation(self, 0.75)}
    var mediumQualityJPEGNSData:NSData  { return UIImageJPEGRepresentation(self, 0.5) }
    var lowQualityJPEGNSData:NSData     { return UIImageJPEGRepresentation(self, 0.25)}
    var lowestQualityJPEGNSData:NSData  { return UIImageJPEGRepresentation(self, 0.0) }
}

class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    var photoSelected: Bool = false
    var thumbnails = [PFFile]()
    var lThreeDict = [String: String]()
    var levelThree = [String]()
    var lFourDict = [String: [String]]()
    var beachIdsDict = [String: String]()
    var beachsDict = [String: [String]]()

    @IBOutlet weak var descriptions: UITextField!
    @IBOutlet weak var imageSelected: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        photoSelected = false
        
        // Fetching from Parse
        descriptions.delegate = self
//        var thumnailQuery = PFQuery(className: "BeachPhotos")
//        thumnailQuery.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
//            if objects != nil{
//                
//                for item in objects!{
//                    //println(item["thumbnail"]!!)
//                    self.thumbnails.append(item["thumbnail"] as! PFFile)
//                    
//                }
//                self.thumbnails[10].getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
//                    
//                    if error == nil{
//                        self.imageSelected.image = UIImage(data: imageData!)
//                    }
//                })
//            }
//        }
        println(thumbnails.count)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func chooseImage(sender: AnyObject) {
        
        var imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.allowsEditing = false
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        println("Image selected")
        self.dismissViewControllerAnimated(true, completion: nil)
        imageSelected.image = image
        photoSelected = true
        
    }
    
    @IBAction func uploadImage(sender: AnyObject) {
        if photoSelected{
            var beachPost = PFObject(className: "Beach")
            beachPost["Description"] = descriptions.text
            let imageData = self.imageSelected.image?.highestQualityJPEGNSData
                        
            let thumbnailData = resizeImage().lowQualityJPEGNSData
            let imageFile = PFFile(name: "image.jpg", data: imageData!)
            let thumbnailFile = PFFile(name: "thumbnail.jpg", data: thumbnailData)
            beachPost["imageFile"] = imageFile
            beachPost["thumbnail"] = thumbnailFile
            beachPost.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if (success == true){
                    println("Image posted successfully!")
                }else{
                    println("Image upload failed!")
                }
            })
        }
    }
    
    func resizeImage() -> UIImage{
        
        var newSize:CGSize = CGSize(width: 250, height: 250)
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        
        self.imageSelected.image?.drawInRect(rect)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        
        textField.resignFirstResponder()
        return true
        
    }

    @IBAction func launchMaps(sender: AnyObject) {
        
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!){
            
            println("Opening Google maps")
            
            UIApplication.sharedApplication().openURL(NSURL(string:"comgooglemaps-x-callback://?saddr=&daddr=Chennai&directionsmode=driving")!)
            
        }else{
            
            println("Opening maps in Safari")
            
            UIApplication.sharedApplication().openURL(NSURL(string:"https://maps.google.com/maps?saddr=&daddr=Chennai&directionsmode=driving")!)
        }
    }
    
    
    @IBAction func testFunction(sender: AnyObject) {
        
        var categoryQuery  = PFQuery(className: "Category")
        categoryQuery.findObjectsInBackgroundWithBlock { (categories, error) -> Void in
            
            if error == nil{
                //println(categories![0].objectForKey("Level")!)
                for item in categories!{
                    
                    if item.objectForKey("Level") as! Int == 3{
                        println(item.objectForKey("CategoryName")!)
                        
                        self.levelThree.append(item.objectForKey("CategoryName") as! String)
                        self.lThreeDict[item.objectForKey("CategoryName") as! String] = item.objectId
                        
                    }else if item.objectForKey("Level") as! Int == 4{
                        
                        if self.lFourDict[item.objectForKey("ParentId") as! String] == nil{
                            
                            var beachArray: [String] = [item.objectForKey("CategoryName") as! String]
                            self.lFourDict[item.objectForKey("ParentId") as! String] = beachArray
                            
                        }else{
                            
                            var updateArray: [String] = self.lFourDict[item.objectForKey("ParentId") as! String]!
                            updateArray.append(item.objectForKey("CategoryName") as! String)
                            self.lFourDict[item.objectForKey("ParentId") as! String] = updateArray
                        }
                        
                        self.beachIdsDict[item.objectForKey("CategoryName") as! String] = item.objectId
                    }
                    
                }
                
                println(self.lThreeDict)
                //println(self.lFourDict)
                self.createBeachesDict()
                println(self.beachIdsDict)
                self.fetchImageObjects()
                
            }else{
                
                println("Category Error:\(error)")
            }
        }
        
    }
    
    func createBeachesDict(){
        
        
        
        for index in 0..<levelThree.count{
            
            beachsDict[levelThree[index]] = lFourDict[lThreeDict[levelThree[index]]!]
        }
        println("beach dict**** \(beachsDict)")
    }
    
    func fetchImageObjects(){
        
        let beachId = self.beachIdsDict["La Cambuse"]
        println(beachId)
        var imageObjectQuery = PFQuery(className: "Beach")
        imageObjectQuery.whereKey("LinkId", equalTo: beachId!)
        imageObjectQuery.findObjectsInBackgroundWithBlock { (imageObjs, error) -> Void in
            
            if error == nil{
                println(imageObjs)
            }else{
                println("Image error: \(error)")
            }
        }
    }
    
    override func shouldAutorotate() -> Bool {
        
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        
        return Int(UIInterfaceOrientation.Portrait.rawValue)
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

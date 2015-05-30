//
//  LargeImageViewController.swift
//  MauritiusExplored
//
//  Created by Niranjan Ravichandran on 06/05/15.
//  Copyright (c) 2015 Adavers. All rights reserved.
//

import UIKit
import Parse

class LargeImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var largeImage: UIImageView!
    @IBOutlet var imageDescription: UILabel!
    @IBOutlet var bookmarkButton: UIButton!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var directionsButton: UIButton!
    var defaults = NSUserDefaults.standardUserDefaults()
    var objectReceived: AnyObject?
    var imageFiles = [PFFile]()
    var descriptionArray = [String]()
    var imageIdArray = [String]()
    var favourites = [String]()
    var selectedCell: Int?
    let tap = UITapGestureRecognizer()
    let doubleTapGesture = UITapGestureRecognizer()
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
    var blurEffectView: UIView!
    var elementsHidden: Bool = false
    var favAdded: Bool = false
    var favImagesId = PFObject(className: "Favourites")
    var favExists: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.scrollView.maximumZoomScale = 5.0
        self.scrollView.clipsToBounds = true
        view.addGestureRecognizer(tap)
        tap.addTarget(self, action: "hideElements")
        
//        doubleTapGesture.numberOfTapsRequired = 2
//        doubleTapGesture.numberOfTouchesRequired = 1
//        doubleTapGesture.addTarget(self, action: "doubleTapAction:")
//        view.addGestureRecognizer(doubleTapGesture)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            println("Going background")
            self.initialLoadingOfObjects()
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // any UI updates need to happen in here back on the main thread
                self.imageDescription.text = self.descriptionArray[self.selectedCell!]
                
                if let favs = self.defaults.objectForKey("Favourites") as? [String]{
                    self.favourites = favs
                    self.favExists = true
                    println(favs)
                    
                    if contains(favs, self.imageIdArray[self.selectedCell!]){
                        self.favAdded = true
                        println("Image already liked")
                        self.bookmarkButton.setTitle("Liked", forState: UIControlState.Normal)
                    }
                }
            })
            
        })
        
    }
    
    // Remove this for double tap zoom
//    func doubleTapAction(recognizer: UITapGestureRecognizer){
//        
//        hideElements()
//        
//        let pointInView = recognizer.locationInView(largeImage)
//        
//        var newZoomScale = scrollView.zoomScale * 2
//        newZoomScale = min(newZoomScale, scrollView.maximumZoomScale)
//        
//        let scrollViewSize = scrollView.bounds.size
//        let w = scrollViewSize.width / newZoomScale
//        let h = scrollViewSize.height / newZoomScale
//        let x = pointInView.x - (w / 2.0)
//        let y = pointInView.y - (h / 2.0)
//        
//        let rectToZoomTo = CGRectMake(x, y, w, h);
//        
//        scrollView.zoomToRect(rectToZoomTo, animated: true)
//    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if !elementsHidden{
            hideElements()
        }
    }
    
    func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView!) {
        if !elementsHidden{
            hideElements()
        }
    }
    
    @IBAction func showDirections(sender: AnyObject) {
        
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!){
            
            println("Opening Google maps")
            
            UIApplication.sharedApplication().openURL(NSURL(string:"comgooglemaps-x-callback://?saddr=&daddr=Roches+Noir&directionsmode=driving")!)
            
        }else{
            
            println("Opening maps in Safari")
            
            UIApplication.sharedApplication().openURL(NSURL(string:"https://maps.google.com/maps?saddr=&daddr=Roches+Noir&directionsmode=driving")!)
        }

    }
    @IBAction func doneAction(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addFavourite(sender: AnyObject) {
        
        if favAdded{
            favAdded = false
            bookmarkButton.setTitle("Like", forState: UIControlState.Normal)
            let newFav = favourites.filter({$0 != self.imageIdArray[self.selectedCell!]})
            favourites = newFav
            println("After removing\(favourites)")
            
        }else{
            favAdded = true
            bookmarkButton.setTitle("Liked", forState: UIControlState.Normal) // updating button text
            favourites.append(imageIdArray[selectedCell!]) // adding to favs
            println(self.imageIdArray[selectedCell!])
            println("After Adding\(favourites)")
            
        }
        defaults.setObject(favourites, forKey: "Favourites") // saving favs to defaults
        
        updateFavouritesToParse()
    }
    
    func updateFavouritesToParse() {
        
        if favExists{
            
            var favUpdateQuery = PFQuery(className: "Favourites")
            favUpdateQuery.whereKey("UserId", equalTo: defaults.objectForKey("UserMail") as! String)
            favUpdateQuery.getFirstObjectInBackgroundWithBlock({ (favObject, error) -> Void in
                
                if error == nil{
                    favObject?.setValue(self.favourites, forKey:"ImageId")
                    favObject?.saveInBackgroundWithBlock{ (updateSuccess: Bool, error: NSError?) -> Void in
                        
                        if updateSuccess == true{
                            println("Favourites upadted")
                        }else{
                            println("Failed to upadte favourites: \(error)")
                        }
                    }
                }
            })

        }else {
            favImagesId["UserId"] = defaults.objectForKey("UserMail")
            favImagesId["ImageId"] = favourites
            favImagesId.saveInBackgroundWithBlock { (updateSuccess: Bool, error: NSError?) -> Void in
                
                if updateSuccess == true {
                    println("Favourites added to parse")
                }else{
                    println("Failed to save Favourites to parse")
                }
            }
        }
    }
    
    func hideElements(){
        
        if !elementsHidden{
            
            self.elementsHidden = true
            self.bookmarkButton.alpha = 0
            self.doneButton.alpha = 0
            self.imageDescription.alpha = 0
            self.directionsButton.alpha = 0
            
        }else{
            
            self.elementsHidden = false
            self.bookmarkButton.alpha = 1
            self.doneButton.alpha = 1
            self.imageDescription.alpha = 1
            self.directionsButton.alpha = 1
        }
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return  true
    }
    
    
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        return largeImage
    }
    
    func initialLoadingOfObjects(){
        
        if let objects: AnyObject = objectReceived{
            
            for item in objects as! [AnyObject]{
                
                self.imageFiles.append(item["imageFile"] as! PFFile)
                self.descriptionArray.append(item["Description"] as! String)
                self.imageIdArray.append(item["imageId"] as! String)
            }
            //            println(self.imageFiles)
            //            println(self.selectedCell)
            imageFiles[self.selectedCell!].getDataInBackgroundWithBlock({ (imageData: NSData?, imageError: NSError?) -> Void in
                
                if imageError == nil{
                    let image = UIImage(data: imageData!)
                    self.largeImage.image = image
                }
            })
        }
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

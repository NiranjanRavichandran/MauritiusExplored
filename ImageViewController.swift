//
//  ImageViewController.swift
//  MauritiusExplored
//
//  Created by Niranjan Ravichandran on 29/05/15.
//  Copyright (c) 2015 Adavers. All rights reserved.
//

import UIKit
import Parse

class ImageViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var largeImageView: UIImageView!
    @IBOutlet var imageDescription: UILabel!
    @IBOutlet var favButton: UIButton!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var directionsButton: UIButton!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var selectedCell: Int?
    var imageDetails: PhotoDetails?
    let tap = UITapGestureRecognizer()
    var elementsHidden: Bool?
    var favourites = [String]()
    var isFavourite: Bool = false
    var favExists: Bool = false
    var lattitude: String?
    var longitude: String?
    var webLink: String?
    var loader = ActivityIndicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.delegate = self
        self.scrollView.maximumZoomScale = 5.0
        self.scrollView.clipsToBounds = true
        elementsHidden = false
        
        tap.addTarget(self, action: "hideElements")
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
        
        loader.startIndicator(UIActivityIndicatorViewStyle.White)
        view.addSubview(loader.activityIndicator!)
        
        if lattitude == nil{
            directionsButton.enabled = false
        }
        loadIntialObjects()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        return largeImageView
    }
    
    func loadIntialObjects(){
      
        imageDescription.text = imageDetails?.imageDesc
        if let favs = defaults.objectForKey("Favourites") as? [String]{
            
            favourites = favs
            favExists = true
            if contains(favourites, self.imageDetails!.imageId){
                println("Image Already Liked")
                favButton.setImage(UIImage(named: "Heart-filled.png"), forState: .Normal)
                isFavourite = true
                println(self.imageDetails!.imageId)
            }else{
                
                println("Not a favourite")
                println(self.imageDetails!.imageId)
                favButton.setImage(UIImage(named: "heart.png"), forState: .Normal)
                isFavourite = false
            }
            
        }
        
        var query = PFQuery(className: "Category")
        query.getObjectInBackgroundWithId(imageDetails!.linkId, block: { (fetchedObject, fetchError) -> Void in
            
            if fetchError == nil{
                let details: CategoryDetails = CategoryDetails(categoryObject: fetchedObject!)
                self.lattitude = details.lattitude
                self.longitude = details.longitude
                self.webLink = details.webLink
                self.directionsButton.enabled = true
            }
        })
        imageDetails?.largeImage.getDataInBackgroundWithBlock({ (imageData, dataError) -> Void in
            
            if dataError == nil{
                
                self.largeImageView.image = UIImage(data: imageData!)
                self.loader.stopIndicator()
            } else{
                
                println("Error fetching image: \(dataError)")
            }
        })
        
        if lattitude != nil || webLink != nil{
            directionsButton.enabled = true
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        if !elementsHidden!{
            hideElements()
            
        }
    }

    func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView!) {
        
        if !elementsHidden!{
            hideElements()
        }
    }

    @IBAction func addFavourites(sender: AnyObject) {
        
        if isFavourite{
            
            favButton.setImage(UIImage(named: "heart.png"), forState: .Normal)
            let newFav = favourites.filter({$0 != self.imageDetails!.imageId})
            favourites = newFav
            isFavourite = false
            //println("Favs after removing: \(favourites)")
            
        }else{
            
            favButton.setImage(UIImage(named: "Heart-filled.png"), forState: .Normal)
            favourites.append(self.imageDetails!.imageId)
            isFavourite = true
            //println("Favs after appending: \(favourites)")
        }
        
        defaults.setObject(favourites, forKey: "Favourites")
        saveFavoruitesToParse()
    }
    
    func saveFavoruitesToParse(){
        
        if favExists{
            
            var favUpdateQuery = PFQuery(className: "Favourites")
            favUpdateQuery.whereKey("UserId", equalTo: defaults.objectForKey("UserMail") as! String)
            favUpdateQuery.getFirstObjectInBackgroundWithBlock({ (favObject, error) -> Void in
                
                if error == nil{
                    favObject?.setValue(self.favourites, forKey:"ImageId")
                    favObject?.saveInBackgroundWithBlock{ (updateSuccess: Bool, error: NSError?) -> Void in
                        
                        if updateSuccess == true{
                            println("Favourites updated")
                        }else{
                            println("Failed to update favourites: \(error)")
                        }
                    }
                }
            })

        }else{
            
            var newFavObject = PFObject(className: "Favourites")
            newFavObject["UserId"] = defaults.objectForKey("UserMail")
            newFavObject["ImageId"] = favourites
            newFavObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                
                if success{
                    
                    println("Favourites added to parse")
                }else{

                    println("Adding Favourites failed")
                }
            })
        }
    }
    
    @IBAction func showDirectionOnMaps(sender: AnyObject) {
        
        if webLink! == "" || webLink == nil {
            println("Open maps")
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!){
                
                //println("Opening Google maps")
                
                UIApplication.sharedApplication().openURL(NSURL(string:"comgooglemaps://?saddr=&daddr=\(lattitude!),\(longitude!)&directionsmode=driving")!)
                
            }else{
                
                //println("Opening Apple maps")
                
                UIApplication.sharedApplication().openURL(NSURL(string:"http://maps.apple.com/?daddr=\(lattitude),\(longitude)&saddr=")!)
                
            }
        }else{
            println("Weblink****\(webLink)")
            UIApplication.sharedApplication().openURL(NSURL(string: self.webLink!)!)
        }
    }
    @IBAction func doneAction(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func hideElements(){
        
        if self.elementsHidden!{
            
            elementsHidden = false
            doneButton.hidden = false
            favButton.hidden = false
            imageDescription.hidden = false
            directionsButton.hidden = false
            
        }else{
            
            elementsHidden = true
            doneButton.hidden = true
            favButton.hidden = true
            imageDescription.hidden = true
            directionsButton.hidden = true
        }
        
    }
    
    override func shouldAutorotate() -> Bool {
        
        return true
    }
    

}

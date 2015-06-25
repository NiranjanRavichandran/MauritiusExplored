//
//  FavsViewController.swift
//  MauritiusExplored
//
//  Created by Niranjan Ravichandran on 22/06/15.
//  Copyright (c) 2015 Adavers. All rights reserved.
//

import UIKit
import Parse

class FavsViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    @IBOutlet var infoText: UILabel!
    @IBOutlet var menuButton: UIBarButtonItem!
    var collectionView: UICollectionView?
    let defaults = NSUserDefaults.standardUserDefaults()
    var favsArray: [String]?
    var favImages = [PhotoDetails]()
    var currentIndex = Int()
    var currenSection = Int()
    var imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favsArray = defaults.objectForKey("Favourites") as? [String]
        
        // Do any additional setup after loading the view.
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        //Custom Activity Indicator
        let activityView : DGActivityIndicatorView = DGActivityIndicatorView(type: DGActivityIndicatorAnimationType.DoubleBounce, tintColor: UIColor.grayColor(), size:30.0)
        activityView.frame = CGRectMake(0, 0, 50, 50)
        activityView.center = view.center
        self.view.addSubview(activityView)
        activityView.startAnimating()
        
        if self.revealViewController() != nil{
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        var index = defaults.objectForKey("CurrentIndex") as! [String: Int]
        currenSection = index["Section"]!
        if currenSection == 2{
            
            if favsArray == nil{
                infoText.alpha = 1
            }
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
            layout.minimumInteritemSpacing = 1
            layout.minimumLineSpacing = 2
            collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
            collectionView?.frame.origin.y = 65
            collectionView?.dataSource = self
            collectionView?.delegate = self
            collectionView?.registerClass(PhotoViewCell.self, forCellWithReuseIdentifier: "Cell")
            collectionView?.backgroundColor = UIColor.clearColor()
            self.view.addSubview(collectionView!)
            activityView.stopAnimating()
            
        }else {
            self.title = "Fly to Mauritius"
            imageView.frame = UIScreen.mainScreen().bounds
            imageView.center = self.view.center
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
            var query = PFQuery(className: "Beach")
            query.getObjectInBackgroundWithId("bFNiCTtXts", block: { (imageObject, imageError) -> Void in
                
                if imageError == nil{
                    let imageDetails: PhotoDetails = PhotoDetails(imageObjects: imageObject!)
                    imageDetails.largeImage.getDataInBackgroundWithBlock({ (imageData, dataError) -> Void in
                        
                        if dataError == nil{
                            self.imageView.image = UIImage(data: imageData!)
                            activityView.stopAnimating()
                        }
                    })
                }
            })
            self.view.addSubview(imageView)
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var items = 0
        if let count = favsArray?.count {
            items = count
        }
        return items
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PhotoViewCell
        cell.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 244/255, alpha: 1.0)
        let imageQuery = PFQuery(className: "Beach")
        imageQuery.getObjectInBackgroundWithId(favsArray![indexPath.row], block: { (fetchedObject, error) -> Void in
            
            let photObject: PhotoDetails = PhotoDetails(imageObjects: fetchedObject!)
            self.favImages.append(photObject)
            if error ==  nil{
                photObject.thumbnail.getDataInBackgroundWithBlock({ (imageData, dataError) -> Void in
                    
                    if dataError == nil{
                        cell.cellImageView.image = UIImage(data: imageData!)
                    }
                })
                
            }
        })
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        var screenWidth = CGRectGetWidth(collectionView.bounds)
        var cellWidth = 50
        if screenWidth == 320{
            cellWidth = 75
        }else if screenWidth == 375{
            cellWidth = 90
        }else if screenWidth == 414{
            cellWidth = 100
        }
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        currentIndex = indexPath.row
        performSegueWithIdentifier("largeFav", sender: self)
    
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var imageVC: ImageViewController = segue.destinationViewController as! ImageViewController
        imageVC.imageDetails = favImages[currentIndex]
        
    }

}

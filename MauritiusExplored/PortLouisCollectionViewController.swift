//
//  PortLouisCollectionViewController.swift
//  MauritiusExplored
//
//  Created by Niranjan Ravichandran on 10/06/15.
//  Copyright (c) 2015 Adavers. All rights reserved.
//

import UIKit
import Parse

class PortLouisCollectionViewController: UICollectionViewController {
    
    let reuseIdentifier = "Cell"
    let defaults = NSUserDefaults.standardUserDefaults()
    var currentIndex = [String: Int]()
    var sortedImages = [String: [PhotoDetails]]()
    var lFourIds = [String]()
    var selectedIndex = NSIndexPath()
    
    @IBOutlet var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentIndex = defaults.objectForKey("CurrentIndex") as! [String: Int]
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        if self.revealViewController() != nil{
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // Register cell classes
        self.collectionView!.registerClass(PhotoViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        //self.collectionView?.backgroundView = UIImageView(image: UIImage(named: "Bg5.jpg"))
        
        // Do any additional setup after loading the view.
        loadInitialObjects()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadInitialObjects(){
        var levelTwoDict = defaults.objectForKey("LevelTwoDict") as! [String: String]
        var currentParent = String()
        
        switch(currentIndex["Section"]!){
       
        case 0:
            if currentIndex["Row"] == 6 || currentIndex["Row"] == 2{
            
            currentParent = levelTwoDict["Port-Louis"]!
        }else if currentIndex["Row"] == 7 || currentIndex["Row"] == 3{
            
            currentParent = levelTwoDict["Ile aux Cerfs"]!
        }else if currentIndex["Row"] == 8 || currentIndex["Row"] == 4{
            
            currentParent = levelTwoDict["Ticabo Diving Centre"]!
        }
        case 1:
            if currentIndex["Row"] == 1{
                
            }else if currentIndex["Row"] == 2{
                
                currentParent = levelTwoDict["Places Of Interest"]!
            }else if currentIndex["Row"] == 3{
                
                currentParent = levelTwoDict["Activities"]!
            }else if currentIndex["Row"] == 4{
                
                currentParent = levelTwoDict["KiteSurf and Wind Surf"]!
            }else if currentIndex["Row"] == 5{

                currentParent = levelTwoDict["Surfing"]!
            }else if currentIndex["Row"] == 6{
                
                currentParent = levelTwoDict["Diving"]!
            }else if currentIndex["Row"] == 7{
                
                currentParent = levelTwoDict["Dolphin Cruise"]!
            }else if currentIndex["Row"] == 8{
                
                currentParent = levelTwoDict["Catamaran Cruise"]!
            }else if currentIndex["Row"] == 9{
                
                currentParent = levelTwoDict["Mountains"]!
            }else if currentIndex["Row"] == 10{
                
                currentParent = levelTwoDict["Professional PhotoGrapher"]!
            }
        default:
            println("Invalid Section")
        }
        println("Current parent: \(currentParent)")
        var imagesQuery = PFQuery(className: "Beach")
        imagesQuery.whereKey("SuperParentId", equalTo: currentParent)
        imagesQuery.limit = 500
        imagesQuery.findObjectsInBackgroundWithBlock { (imageObjects, error) -> Void in
            
            if error == nil{
                
                for item in imageObjects!{
                    
                    if !contains(self.lFourIds, item.objectForKey("LinkId") as! String){
                    self.lFourIds.append(item.objectForKey("LinkId") as! String)
                    }
                    if self.sortedImages[item.objectForKey("LinkId") as! String] == nil{
                        let photoObject = PhotoDetails(imageObjects: item)
                        var photoDtlsArray: [PhotoDetails] = [photoObject]
                        self.sortedImages[item.objectForKey("LinkId") as! String] = photoDtlsArray
                    }else{
                        var photoDtlsArray: [PhotoDetails] = self.sortedImages[item.objectForKey("LinkId") as! String]!
                        let photoObject = PhotoDetails(imageObjects: item)
                        photoDtlsArray.append(photoObject)
                        self.sortedImages[item.objectForKey("LinkId") as! String] = photoDtlsArray
                    }
                }
                // println(self.lFourIds)
                // println(self.sortedImages)
                self.collectionView?.reloadData()
            }else{
                
                println("Error fetching data frpm parse")
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return lFourIds.count
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        println(lFourIds[section])
        let items = sortedImages[lFourIds[section]]
        return items!.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoViewCell
        cell.backgroundColor = UIColor.darkGrayColor()
        
        // Configure the cell
        if sortedImages.count > 0{
            
            let imageDetailsArray: [PhotoDetails] = sortedImages[lFourIds[indexPath.section]]!
            imageDetailsArray[indexPath.row].thumbnail.getDataInBackgroundWithBlock({ (imageData, dataError) -> Void in
                
                if dataError ==  nil{
                    cell.cellImageView.image = UIImage(data: imageData!)
                }else{
                    
                    println("Error fetching thumbnail: \(dataError)")
                }
            })
            
        }
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        switch kind{
            
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! CollectionViewHeader
            headerView.pHeaderText.text = "Header"
            headerView.alpha = 0.7
            return headerView
            
        default:
            
            assert(false, "Unexpected element Kind")
        }
        
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        selectedIndex = indexPath
        performSegueWithIdentifier("StretchImage", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var imageVC: ImageViewController = segue.destinationViewController as! ImageViewController
        let imageDetailsArray: [PhotoDetails] = sortedImages[lFourIds[selectedIndex.section]]!
        imageVC.imageDetails = imageDetailsArray[selectedIndex.row]
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            
            //            var screenWidth = CGRectGetWidth(collectionView.bounds)
            //            var cellWidth = screenWidth / 3
            
            return CGSize(width: 75,height: 75)
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
            return 5
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
            return 1
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            
            return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    
    // MARK: UICollectionViewDelegate
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
}

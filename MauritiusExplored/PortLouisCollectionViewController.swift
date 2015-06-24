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
    var levelFourDict = [String: String]()
    var currentHeading = String()
    
    @IBOutlet var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentIndex = defaults.objectForKey("CurrentIndex") as! [String: Int]
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        levelFourDict = defaults.objectForKey("LevelFour") as! [String: String]
        
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
        println(levelTwoDict)
        var currentParent = String()
        var loader = ActivityIndicator()
        loader.startIndicator(UIActivityIndicatorViewStyle.Gray)
        view.addSubview(loader.activityIndicator!)
        
        switch(currentIndex["Section"]!){
            
        case 0:
            if currentIndex["Row"] == 6 || currentIndex["Row"] == 2{
                currentHeading = "Port-Louis"
                currentParent = levelTwoDict[currentHeading]!
            }else if currentIndex["Row"] == 7 || currentIndex["Row"] == 3{
                currentHeading = "Ile aux Cerfs"
                currentParent = levelTwoDict[currentHeading]!
            }else if currentIndex["Row"] == 8 || currentIndex["Row"] == 4{
                currentHeading = "Ticabo Diving Centre"
                currentParent = levelTwoDict[currentHeading]!
            }else if currentIndex["Row"] == 9 || currentIndex["Row"] == 5{
                currentHeading = "Airport"
                currentParent = levelTwoDict[currentHeading]!
                println("Parent: \(currentParent)")
            }
        case 1:
            if currentIndex["Row"] == 1{
                
            }else if currentIndex["Row"] == 2{
                currentHeading = "Places Of Interest"
                currentParent = levelTwoDict[currentHeading]!
            }else if currentIndex["Row"] == 3{
                currentHeading = "Activities"
                currentParent = levelTwoDict[currentHeading]!
            }else if currentIndex["Row"] == 4{
                currentHeading = "KiteSurf and Wind Surf"
                currentParent = levelTwoDict[currentHeading]!
            }else if currentIndex["Row"] == 5{
                currentHeading = "Surfing"
                currentParent = levelTwoDict[currentHeading]!
            }else if currentIndex["Row"] == 6{
                currentHeading = "Diving"
                currentParent = levelTwoDict[currentHeading]!
            }else if currentIndex["Row"] == 7{
                currentHeading = "Dolphin Cruise"
                currentParent = levelTwoDict[currentHeading]!
            }else if currentIndex["Row"] == 8{
                currentHeading = "Catamaran Cruise"
                currentParent = levelTwoDict[currentHeading]!
            }else if currentIndex["Row"] == 9{
                currentHeading = "Mountains"
                currentParent = levelTwoDict[currentHeading]!
            }else if currentIndex["Row"] == 10{
                currentHeading = "Professional PhotoGrapher"
                currentParent = levelTwoDict[currentHeading]!
            }
        default:
            println("Invalid Section")
        }
        self.title = currentHeading
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
                loader.stopIndicator()
            }else{
                
                if error?.code == 100{
                    
                    self.displayErrorView()
                }
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return lFourIds.count
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
        
        var headerString = NSString()
        switch kind{
    
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! CollectionViewHeader
            if lFourIds.count > 1{
                
                headerView.pHeaderText.text = levelFourDict[lFourIds[indexPath.section]]
                headerString = levelFourDict[lFourIds[indexPath.section]]!
            }else{
                headerView.pHeaderText.text = currentHeading
                headerString = currentHeading
            }
            
            var newSize: CGSize = headerString.sizeWithAttributes([NSFontAttributeName: headerView.pHeaderText.font])
            headerView.frame.size.width = newSize.width + 20
            headerView.layer.cornerRadius = 15
            headerView.center.x = collectionView.center.x
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
    
    func displayErrorView(){
        
        let controller: BadConnectionView = self.storyboard?.instantiateViewControllerWithIdentifier("NoConnectionView") as! BadConnectionView
        self.addChildViewController(controller)
        controller.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        self.view.addSubview(controller.view)
        self.view.center = (self.view.superview?.center)!
        controller.didMoveToParentViewController(self)
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

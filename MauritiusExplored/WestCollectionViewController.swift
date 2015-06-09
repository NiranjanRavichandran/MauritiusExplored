//
//  WestCollectionViewController.swift
//  MauritiusExplored
//
//  Created by Niranjan Ravichandran on 28/05/15.
//  Copyright (c) 2015 Adavers. All rights reserved.
//

import UIKit
import Parse

let reuseIdentifier = "Cell"
let defaults = NSUserDefaults.standardUserDefaults()
var sortedImagesDict = [String: [PhotoDetails]]()
var sectionItemsCount = 0

class WestCollectionViewController: UICollectionViewController {
    
    @IBOutlet var menuButton: UIBarButtonItem!
    var currentBeachDirection: String?
    let beachNames = defaults.objectForKey("BeachNames") as! [String: [String]]
    let beachIdsDict = defaults.objectForKey("BeachIds") as! [String: String]
    let directionsDict = defaults.objectForKey("DirectionsDict") as! [String: String]
    var cellIndexPath = NSIndexPath()
    var westBeaches = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sortedImagesDict.removeAll(keepCapacity: false)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        self.collectionView!.registerClass(PhotoViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        self.collectionView?.backgroundView = UIImageView(image: UIImage(named: "GirlPortarit.jpg"))
        
        if self.revealViewController() != nil{
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        var loader = ActivityIndicator()
        loader.startIndicator()
        view.addSubview(loader.activityIndicator!)

        // Do any additional setup after loading the view.
        if let direction = defaults.objectForKey("CurrentDirection") as? String{
            
            currentBeachDirection = direction
            
        }else{
            currentBeachDirection = "East"
        }
        
        println("Loading \(currentBeachDirection) Objects")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            PFUser.logInWithUsernameInBackground(defaults.objectForKey("UserMail") as! String, password: "password") { (userObject, error) -> Void in
                
                if error == nil{
                    
                    println("Logged In")
                    self.loadingObjects()
                    loader.stopIndicator()
                }else{
                    println("Login failed!")
                }
            }
        })
        
    }
    
    func loadingObjects(){
        
        westBeaches = beachNames[currentBeachDirection!]!
        
        var imagesQuery = PFQuery(className: "Beach")
        imagesQuery.whereKey("SuperParentId", equalTo: directionsDict[currentBeachDirection!]!)
        imagesQuery.findObjectsInBackgroundWithBlock { (imageObjects, error) -> Void in
            
            if error == nil{
                
                for item in imageObjects!{
                    
                    if sortedImagesDict[item.objectForKey("LinkId") as! String] == nil{
                        //println("Adding new array")
                        let photoObject = PhotoDetails(imageObjects: item)
                        var photoDtlsArray: [PhotoDetails] = [photoObject]
                        sortedImagesDict[item.objectForKey("LinkId") as! String] = photoDtlsArray
                        
                    }else{
                        
                       // println("appending data")
                        var photoDtlsArray: [PhotoDetails] = sortedImagesDict[item.objectForKey("LinkId") as! String]!
                        let photoObject = PhotoDetails(imageObjects: item)
                        photoDtlsArray.append(photoObject)
                        sortedImagesDict[item.objectForKey("LinkId") as! String] = photoDtlsArray
                    }
                    
                }
                
                self.loadThumbnails()
             //   println(sortedImagesDict)
                self.collectionView?.reloadData()
                
            }else{
                
                println("Fetching image error **** \(error)")
            }
        }
    }
    
    func loadThumbnails(){
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return sortedImagesDict.count
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        var beach = westBeaches[section]
        var items = sortedImagesDict[beachIdsDict[beach]!]
        return items!.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoViewCell
        cell.backgroundColor = UIColor.darkGrayColor()
        // Configure the cell
        if sortedImagesDict.count > 0 {
            let imageDetailsArray: [PhotoDetails] = sortedImagesDict[beachIdsDict[westBeaches[indexPath.section]]!]!
            
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
            var headerString = westBeaches[indexPath.section] as NSString
            var newSize: CGSize = headerString.sizeWithAttributes([NSFontAttributeName:headerView.headerText.font])
            headerView.frame.size.width = newSize.width + 20
            headerView.layer.cornerRadius = 15
            headerView.headerText.text = westBeaches[indexPath.section]
            headerView.center.x = collectionView.center.x
            headerView.alpha = 0.7
            return headerView
            
        default:
            
            assert(false, "Unexpected element Kind")
            
        }
        
    }
    
     override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        
        collectionView!.performBatchUpdates({ () -> Void in
            
        self.view.layoutIfNeeded()
            }, completion: { (complete) -> Void in
                
        })
    
    }

    override func shouldAutorotate() -> Bool {
        return false
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
    
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        cellIndexPath = indexPath
        performSegueWithIdentifier("LargeImageView", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var imageVC: ImageViewController = segue.destinationViewController as! ImageViewController
        let imageDetailsArray: [PhotoDetails] = sortedImagesDict[beachIdsDict[westBeaches[cellIndexPath.section]]!]!
        imageVC.imageDetails = imageDetailsArray[cellIndexPath.row]
        
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            
            return UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    }
    
    
//    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
//        
//        if fromInterfaceOrientation.rawValue == UIInterfaceOrientation.Portrait.rawValue{
//            UICollectionView.animateWithDuration(0.5, animations: { () -> Void in
//                self.collectionView?.backgroundView = UIImageView(image: UIImage(named: "lanscape.jpg"))
//            })
//        }else{
//            UICollectionView.animateWithDuration(0.5, animations: { () -> Void in
//                
//                self.collectionView?.backgroundView = UIImageView(image: UIImage(named: "GirlPortarit.jpg"))
//                
//            })
//        }
//    }
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

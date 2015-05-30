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
    var currentBeachDirection: String = "East"
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
        
        if self.revealViewController() != nil{
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        // Do any additional setup after loading the view.
        if let direction = defaults.objectForKey("CurrentDirection") as? String{
            
            currentBeachDirection = direction
            
        }
        
        println("Loading West Objects")
        loadingObjects()
    }
    
    func loadingObjects(){
        
        westBeaches = beachNames[currentBeachDirection]!
        
        var imagesQuery = PFQuery(className: "Beach")
        imagesQuery.whereKey("SuperParentId", equalTo: directionsDict[currentBeachDirection]!)
        imagesQuery.findObjectsInBackgroundWithBlock { (imageObjects, error) -> Void in
            
            if error == nil{
                
                for item in imageObjects!{
                    
                    if sortedImagesDict[item.objectForKey("LinkId") as! String] == nil{
                        println("Adding new array")
                        let photoObject = PhotoDetails(imageObjects: item)
                        var photoDtlsArray: [PhotoDetails] = [photoObject]
                        sortedImagesDict[item.objectForKey("LinkId") as! String] = photoDtlsArray
                        
                    }else{
                        
                        println("appending data")
                        var photoDtlsArray: [PhotoDetails] = sortedImagesDict[item.objectForKey("LinkId") as! String]!
                        let photoObject = PhotoDetails(imageObjects: item)
                        photoDtlsArray.append(photoObject)
                        sortedImagesDict[item.objectForKey("LinkId") as! String] = photoDtlsArray
                    }
                    
                }
                
                self.loadThumbnails()
                println(sortedImagesDict)
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
        println("Section number **** \(section)")
        var beach = westBeaches[section]
        var items = sortedImagesDict[beachIdsDict[beach]!]
        println("items in this section: \(items!.count)")
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
            headerView.headerText.text = westBeaches[indexPath.section]
            return headerView
            
        default:
            
            assert(false, "Unexpected element Kind")
            
        }
        
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
            return 1
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

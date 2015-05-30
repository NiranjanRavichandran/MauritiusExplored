//
//  CollectionViewController.swift
//  MauritiusExplored
//
//  Created by Niranjan Ravichandran on 29/04/15.
//  Copyright (c) 2015 Adavers. All rights reserved.
//

import UIKit
import Parse

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let reuseIdentifier = "Cell"
    //private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    let defaults = NSUserDefaults.standardUserDefaults()
    var fetchedObject: AnyObject?
    var thumbnails = [PFFile]()
    var thumnailData = [NSData]()
    var cellIndex: Int?
    //var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        self.collectionView!.registerClass(PhotoViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)        
        
        // Do any additional setup after loading the view.
        if self.revealViewController() != nil{
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        var loader = ActivityIndicator()
        loader.startIndicator()
        view.addSubview(loader.blurredView)
        
        //Perfroming Login
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            PFUser.logInWithUsernameInBackground(self.defaults.objectForKey("UserMail") as! String, password: "password") { (userObject, error) -> Void in
                
                if error == nil{
                    println("Logged in!")
                    // Fetching from Parse
                    println("Fetching from parse")
                    var thumnailQuery = PFQuery(className: "BeachPhotos")
                    thumnailQuery.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
                        if objects != nil{
                            
                            self.fetchedObject = objects
                            
                            for item in objects!{
                                //println(item["thumbnail"]!!)
                                self.thumbnails.append(item["thumbnail"] as! PFFile)
                            }
                        }else{
                            println("Retrieve failed:\(error)")
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in

                            //println("Files retrieved from parse: \(self.fetchedObject)")
                            self.collectionView?.reloadData()
                            loader.stopIndicator()
                            //view.removeFromSuperview()
                            
                        })
                                            }
                }else{
                    println("Login error:\(error)")
                }
            }
        })
        
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
        return 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return thumbnails.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoViewCell
        
        // Configure the cell
        cell.backgroundColor = UIColor.darkGrayColor()
        
        if thumbnails.count > 0{
            thumbnails[indexPath.row].getDataInBackgroundWithBlock({ (imageData: NSData?, imageError: NSError?) -> Void in
                
                if imageError == nil{
                    let image = UIImage(data: imageData!)
                    cell.cellImageView.image = image
                }
            })
            //println("Thumbnail images Loaded!")
        }

        return cell
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            
            var screenWidth = CGRectGetWidth(collectionView.bounds)
            var cellWidth = screenWidth / 3
            
            return CGSize(width: cellWidth - 1, height: cellWidth - 1)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var largeImageVC: LargeImageViewController = segue.destinationViewController as! LargeImageViewController
        
        largeImageVC.objectReceived = fetchedObject
        largeImageVC.selectedCell = cellIndex!
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        
        cellIndex = indexPath.row
        performSegueWithIdentifier("ImageViewer", sender: self)
    }
    
    override func shouldAutorotate() -> Bool {
        
        return false
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        switch kind{
            
        case UICollectionElementKindSectionHeader:
            
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! CollectionViewHeader
            //headerView.headerText.text = "Sample Heading!"
            return headerView
            
        default:
            
            assert(false, "Unexpected element Kind")

        }
        
    }
    
    // for custom grid layout...
    //        func collectionView(collectionView: UICollectionView,
    //            layout collectionViewLayout: UICollectionViewLayout,
    //            insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    //
    //                return sectionInsets
    //        }
    
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

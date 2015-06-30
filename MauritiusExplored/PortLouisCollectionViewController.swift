//
//  PortLouisCollectionViewController.swift
//  MauritiusExplored
//
//  Created by Niranjan Ravichandran on 10/06/15.
//  Copyright (c) 2015 Adavers. All rights reserved.
//

import UIKit
import Parse
import StoreKit

var isPurchased: Bool = false

class PortLouisCollectionViewController: UICollectionViewController, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    var product: SKProduct?
    var productResponse: SKProductsResponse?
    var productId = "MauritiusExplored26615"
    let reuseIdentifier = "Cell"
    let defaults = NSUserDefaults.standardUserDefaults()
    var currentIndex = [String: Int]()
    var sortedImages = [String: [PhotoDetails]]()
    var lFourIds = [String]()
    var selectedIndex = NSIndexPath()
    var levelFourDict = [String: String]()
    var currentHeading = String()
    var paymentView: UIView?
    var buyNowButton: UIButton = UIButton(frame: CGRectMake(0, 0, 130, 35))
    var activityRedView: DGActivityIndicatorView?
    var isCenter: Bool = false
    
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
        collectionView?.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        //self.collectionView?.backgroundView = UIImageView(image: UIImage(named: "Bg5.jpg"))
        
        isPurchased = defaults.boolForKey("isPurchased")
        // Do any additional setup after loading the view.
        if currentIndex["Section"] == 1{
            if !isPurchased{
                
                loadPurchaseView()
                
            }else{
                
                loadInitialObjects()
            }
        }else{
            loadInitialObjects()
        }
        
    }
    
    func loadPurchaseView(){
        self.title = "Purchase Required"
        paymentView = UIView(frame: UIScreen.mainScreen().bounds)
        paymentView!.backgroundColor = UIColor.whiteColor()
        
        buyNowButton.center = paymentView!.center
        buyNowButton.center.y = paymentView!.center.y + 20
        buyNowButton.setBackgroundImage(UIImage(named: "BuyButton.png"), forState: .Normal)
        buyNowButton.addTarget(self, action: "invokePayment", forControlEvents: UIControlEvents.TouchUpInside)
        paymentView!.addSubview(buyNowButton)
        buyNowButton.enabled = false
        
        let text: NSString = "Discover more than the island and experience Mauritius."
        var paymentInfo: UILabel = UILabel(frame: CGRectMake(0, 0 - 20, 320, 40))
        paymentInfo.font = UIFont(name: "Helvetica Neue", size: 14)
        paymentInfo.numberOfLines = 3
        paymentInfo.textAlignment = .Center
        paymentInfo.center.x = paymentView!.center.x
        paymentInfo.center.y = (paymentView!.center.y - 30)
        paymentInfo.text = text as String
        paymentInfo.textColor = UIColor.grayColor()
        paymentView!.addSubview(paymentInfo)
        self.view.addSubview(paymentView!)
        
        activityRedView = DGActivityIndicatorView(type: DGActivityIndicatorAnimationType.DoubleBounce, tintColor: UIColor.redColor(), size:30.0)
        activityRedView!.frame = CGRectMake(0, 0, 50, 50)
        activityRedView!.center.x = view.center.x
        activityRedView?.center.y = view.center.y - 90
        self.view.addSubview(activityRedView!)
        activityRedView!.startAnimating()
        
        //Get product info
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        if SKPaymentQueue.canMakePayments() {
            
            let request = SKProductsRequest(productIdentifiers:
                NSSet(objects: self.productId) as Set<NSObject>)
            request.delegate = self
            request.start()
            //println("purchase is available!")
            
        } else {
            
            SCLAlertView().showWarning("Oops!", subTitle:"Please enable In App Purchase in Settings and try again", closeButtonTitle:"OK")
        }

    }
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        //println("Getting product details")
        var products = response.products
        if(products.count != 0){
            product = products[0] as? SKProduct
            buyNowButton.enabled = true
        }else{
            SCLAlertView().showError("Error", subTitle:"Product not found.", closeButtonTitle:"OK")
        }
        
        products = response.invalidProductIdentifiers
        
        for product in products
        {
            //println("Product not found: \(product)")
            SCLAlertView().showError("Product not found", subTitle:"\(product)", closeButtonTitle:"OK")
        }
        
        activityRedView?.stopAnimating()
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        
        //println("Invoking payment method***")
        buyNowButton.enabled = false
        for transaction in transactions as! [SKPaymentTransaction] {
            
            switch transaction.transactionState {
                
            case SKPaymentTransactionState.Purchased:
                isPurchased = true
                SCLAlertView().showSuccess("Success", subTitle:"Loading newly purchased content...", closeButtonTitle:"OK")
                loadInitialObjects()
                self.paymentView?.removeFromSuperview()
                defaults.setBool(true, forKey: "isPurchased")
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                
            case SKPaymentTransactionState.Failed:
                SCLAlertView().showError("Error", subTitle:"Transaction aborted. Please try again.", closeButtonTitle:"OK")
                buyNowButton.enabled = true
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                
            default:
                break
            }
        }
    }
    
    func invokePayment(){
        
        let noticeAlert = SCLAlertView()
        noticeAlert.addButton("Buy", action: { () -> Void in
            let payment = SKPayment(product: self.product)
            SKPaymentQueue.defaultQueue().addPayment(payment)

        })
        noticeAlert.showNotice(product!.localizedTitle, subTitle:product!.localizedDescription, closeButtonTitle:"Cancel")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadInitialObjects(){
        
        var levelTwoDict = defaults.objectForKey("LevelTwoDict") as! [String: String]
        var currentParent = String()
        //Custom Activity Indicator
        let activityView = DGActivityIndicatorView(type: DGActivityIndicatorAnimationType.DoubleBounce, tintColor: UIColor.grayColor(), size:30.0)
        activityView.frame = CGRectMake(0, 0, 50, 50)
        activityView.center = view.center
        self.view.addSubview(activityView!)
        activityView.startAnimating()
        
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
                //println("Parent: \(currentParent)")
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
                activityView.stopAnimating()
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
        if items?.count < 2{
            isCenter = true
        }
        return items!.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoViewCell
        cell.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 244/255, alpha: 1.0)
        
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
        
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! CollectionViewHeader
        if lFourIds.count > 1{
            
            headerView.pHeaderText.text = levelFourDict[lFourIds[indexPath.section]]
            headerString = levelFourDict[lFourIds[indexPath.section]]!
        }else{
            headerView.pHeaderText.text = currentHeading
            headerString = currentHeading
        }
        
        var newSize: CGSize = headerString.sizeWithAttributes([NSFontAttributeName: headerView.pHeaderText.font])
//        headerView.frame.size.width = newSize.width + 20
//        headerView.layer.cornerRadius = 15
//        headerView.center.x = collectionView.center.x
        headerView.alpha = 0.7
        return headerView
        
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
            var sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            if isCenter{
                let size = UIScreen.mainScreen().bounds.width / 3
                sectionInset = UIEdgeInsets(top: 5, left: size, bottom: 5, right: size)
            }
            return sectionInset
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

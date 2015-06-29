//
//  FavsViewController.swift
//  MauritiusExplored
//
//  Created by Niranjan Ravichandran on 22/06/15.
//  Copyright (c) 2015 Adavers. All rights reserved.
//

import UIKit
import Parse
import StoreKit

class FavsViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    @IBOutlet var infoText: UILabel!
    @IBOutlet var menuButton: UIBarButtonItem!
    var collectionView: UICollectionView?
    let defaults = NSUserDefaults.standardUserDefaults()
    var favsArray: [String]?
    var favImages = [PhotoDetails]()
    var currentIndex = Int()
    var currenSection = Int()
    var imageView = UIImageView()
    var paymentView: UIView?
    var buyNowButton: UIButton = UIButton(frame: CGRectMake(0, 0, 130, 35))
    var activityRedView: DGActivityIndicatorView?
    var product: SKProduct?
    var productId = "MauritiusExplored26615"
    var activityView : DGActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favsArray = defaults.objectForKey("Favourites") as? [String]
        
        // Do any additional setup after loading the view.
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        //Custom Activity Indicator
        activityView = DGActivityIndicatorView(type: DGActivityIndicatorAnimationType.DoubleBounce, tintColor: UIColor.grayColor(), size:30.0)
        activityView?.frame = CGRectMake(0, 0, 50, 50)
        activityView?.center = view.center
        self.view.addSubview(activityView!)
        activityView?.startAnimating()
        
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
            activityView?.stopAnimating()
            
        }else {
            
            if defaults.boolForKey("isPurchased"){
               
                loadFlyToMauritius()
                
            }else{
                
                activityView?.stopAnimating()
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
                    println("purchase is available!")
                    
                } else {
                    
                    SCLAlertView().showWarning("Oops!", subTitle:"Please enable In App Purchase in Settings and try again", closeButtonTitle:"OK")
                }
            }
        }
    }
    
    func loadFlyToMauritius(){
       
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
                        self.activityView?.stopAnimating()
                    }
                })
            }
        })
        self.view.addSubview(imageView)
    }
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        println("Getting product details")
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
            println("Product not found: \(product)")
        }
        
        activityRedView?.stopAnimating()
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        
        println("Invoking payment method***")
        buyNowButton.enabled = false

        for transaction in transactions as! [SKPaymentTransaction] {
            
            switch transaction.transactionState {
                
            case SKPaymentTransactionState.Purchased:
                isPurchased = true
                SCLAlertView().showSuccess("Success", subTitle:"Loading newly purchased content...", closeButtonTitle:"OK")
                loadFlyToMauritius()
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

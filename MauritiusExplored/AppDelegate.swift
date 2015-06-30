//
//  AppDelegate.swift
//  MauritiusExplored
//
//  Created by Niranjan Ravichandran on 25/04/15.
//  Copyright (c) 2015 Adavers. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let defaults = NSUserDefaults.standardUserDefaults()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Parse.enableLocalDatastore()
        
        //Initialze Parse.
        Parse.setApplicationId("PMipl2gmbDK4b1UTaBBb9XTU8VADHnpPtiZxoVEo",
        clientKey: "12DLcXOAgsqNZLn6lp7oYwKsSoqWPNdi3WjDJ6T2")
        
        //Navigation bar styles
        UINavigationBar.appearance().barTintColor = UIColor(red:226/255, green: 60/255, blue: 45/255, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().setBackgroundImage(UIImage(named: "NavBar2.jpg"), forBarMetrics: .Default)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        loadCategories()
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
        
        return true
    }
    
    // Function to create the intial view after launch
    func creatingIntialView(storyboardId: String){
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        var initialViewController = storyboard.instantiateViewControllerWithIdentifier(storyboardId) as! UIViewController
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
    }
    
    func loadCategories(){
        
        if defaults.objectForKey("LevelFour") == nil {

            var levelTwo = [String]()
            var lTwoDict = [String: String]()
            var lThreeDict = [String: String]()
            var levelThree = [String]()
            var lFourDict = [String: [String]]()
            var beachIdsDict = [String: String]()
            var beachsDict = [String: [String]]()
            var lThreeIdArray = [String]()
            var beachIds = [CategoryDetails]()
            var levelFourDict = [String: String]()
            
            var categoryQuery  = PFQuery(className: "Category")
            categoryQuery.limit = 500
            categoryQuery.findObjectsInBackgroundWithBlock { (categories, error) -> Void in
                
                if error == nil{
                    for item in categories!{
                        if item.objectForKey("Level") as! Int == 2{
                            
                            levelTwo.append(item.objectForKey("CategoryName") as! String)
                            lTwoDict[item.objectForKey("CategoryName") as! String] = item.objectId
                            
                        }else if item.objectForKey("Level") as! Int == 3{
                            //println(item.objectForKey("CategoryName")!)
                            
                            levelThree.append(item.objectForKey("CategoryName") as! String)
                            lThreeDict[item.objectForKey("CategoryName") as! String] = item.objectId
                            lThreeIdArray.append(item.objectId!!)
                            
                        }else if item.objectForKey("Level") as! Int == 4{
                            
                            levelFourDict[item.objectId!!] = item.objectForKey("CategoryName") as? String
                            if lFourDict[item.objectForKey("ParentId") as! String] == nil{
                                
                                var beachArray: [String] = [item.objectForKey("CategoryName") as! String]
                                lFourDict[item.objectForKey("ParentId") as! String] = beachArray
                                
                            }else{
                                
                                var updateArray: [String] = lFourDict[item.objectForKey("ParentId") as! String]!
                                updateArray.append(item.objectForKey("CategoryName") as! String)
                                lFourDict[item.objectForKey("ParentId") as! String] = updateArray
                            }
                            
                            beachIds.append(CategoryDetails(categoryObject: item))
                        }
                        
                    }
                    
                    for index in 0..<beachIds.count{
                        if contains(lThreeIdArray, beachIds[index].parentId){
                            
                            var categoryName = beachIds[index].name
                            beachIdsDict[categoryName] = beachIds[index].objectId
                        }
                    }
                    // Populating Beaches Dictionary
                    for index in 0..<levelThree.count{
                        beachsDict[levelThree[index]] = lFourDict[lThreeDict[levelThree[index]]!]
                    }
                    //println(lFourDict)
                    self.defaults.setObject(beachIdsDict, forKey: "BeachIds")
                    self.defaults.setObject(beachsDict, forKey: "BeachNames")
                    self.defaults.setObject(lThreeDict, forKey: "DirectionsDict")
                    self.defaults.setObject(lTwoDict, forKey: "LevelTwoDict")
                    self.defaults.setObject(levelTwo, forKey: "LevelTwo")
                    self.defaults.setObject(levelFourDict, forKey: "LevelFour")
                    
                    //Launching initial view
                    self.launchInitialView()
                    
                }else{
                    
                    if error?.code == 100{
                        self.creatingIntialView("SignUpView")
                    }
                }
            }
        } else{
            
            launchInitialView()
        }

    }
    
    func launchInitialView(){
        
        if self.defaults.objectForKey("UserMail")  == nil {
            
            //println("First Launch")
            self.creatingIntialView("SignUpView")
            
        }else{
            
            let email = self.defaults.objectForKey("UserMail") as! String
            if email == "" {
                
                //println("Not First Launch")
                self.creatingIntialView("SignUpView")
                
            }else{
                
                //println("Not first Launch")
                self.creatingIntialView("MenuView")
                
                let getFavQuery = PFQuery(className: "Favourites")
                getFavQuery.whereKey("UserId", equalTo: email)
                getFavQuery.getFirstObjectInBackgroundWithBlock({ (favObject, error) -> Void in
                    
                    if error == nil{
                        
                        let favs = favObject?.valueForKey("ImageId") as! [String]
                        self.defaults.setObject(favs, forKey: "Favourites")
                    }
                })
            }
        }

    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        println("Logging out...")
        PFUser.logOut()
    }
    
    
}


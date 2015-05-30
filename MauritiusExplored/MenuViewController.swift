//
//  MenuViewController.swift
//  MauritiusExplored
//
//  Created by Niranjan Ravichandran on 04/05/15.
//  Copyright (c) 2015 Adavers. All rights reserved.
//

import UIKit

class MenuViewController: StaticDataTableViewController {

    
    @IBOutlet var beachMenu: [UITableViewCell]!
    var cellsHidden = true
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        //tableView.backgroundView = UIImageView(image: UIImage(named: "MenuB.jpeg"))
        self.tableView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.2)
        
        self.insertTableViewRowAnimation = UITableViewRowAnimation.Bottom
        self.deleteTableViewRowAnimation = UITableViewRowAnimation.Fade
        
        self.cells(beachMenu, setHidden: true)
        self.reloadDataAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func shouldAutorotate() -> Bool {

        return false
        
    }
    
    override func supportedInterfaceOrientations() -> Int {
        
        return Int(UIInterfaceOrientation.Portrait.rawValue)
    }
    // MARK: - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Potentially incomplete method implementation.
//        // Return the number of sections.
//        return 0
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete method implementation.
//        // Return the number of rows in the section.
//        return 0
//    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.None

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var selectedCell = tableView.cellForRowAtIndexPath(indexPath)
       // selectedCell?.backgroundColor = UIColor.grayColor()
        
        if selectedCell?.tag == 11{
            println("East")
            defaults.setObject("East", forKey: "CurrentDirection")
            performSegueWithIdentifier("East", sender: self)
        }else if selectedCell?.tag == 12{
            println("West")
            defaults.setObject("West", forKey: "CurrentDirection")
            performSegueWithIdentifier("West", sender: self)
        }else if selectedCell?.tag == 13{
            println("North")
            defaults.setObject("North", forKey: "CurrentDirection")
           performSegueWithIdentifier("North", sender: self)
        }else if selectedCell?.tag == 14{
            println("South")
            defaults.setObject("South", forKey: "CurrentDirection")
            performSegueWithIdentifier("South", sender: self)
        }
        
        if indexPath.row == 1{
            
            
            if cellsHidden{
                
                self.cells(beachMenu, setHidden: false)
                self.reloadDataAnimated(true)
                cellsHidden = false
                
            }else{
                
                cellsHidden = true
                self.cells(beachMenu, setHidden: true)
                self.reloadDataAnimated(true)
                
            }
        }
 
    }
    
//    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
//        
//        var cellToDeSelect = tableView.cellForRowAtIndexPath(indexPath)
//        cellToDeSelect?.backgroundColor = UIColor.purpleColor()
//    }
    
}

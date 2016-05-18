//
//  MasterViewController.swift
//  iBanksUA
//
//  Created by Taras Pasichnyk on 5/16/16.
//  Copyright © 2016 Taras Pasichnyk. All rights reserved.
//

import UIKit
import SwiftyJSON

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var cities = [String]()
    var cityKeys = [String]()

    var menuWasShown = false
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
        self.reloadTableView()
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
        
        if !menuWasShown {
            mainMenuViewController.showMainMenuOnController(self)
            menuWasShown = true
        }
    }
    
}

    // MARK: Helpers
extension MasterViewController {
    
    func reloadTableView() {
        mainMenuViewController.allJsonData { (result) in
 
            let allCities = result["cities"]
            
            for (key, object) in allCities {
                if !self.cities.contains(object.stringValue) {
                    self.cities.append(object.stringValue)
                }
                if !self.cityKeys.contains(key) {
                    self.cityKeys.append(key)
                }
            }
            
            self.tableView.reloadData()
            
        }
    }
    
}

    // MARK: Segues
extension MasterViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "setDesiredCity" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = cityKeys[indexPath.row]
                let controller = segue.destinationViewController as! BanksViewController
                controller.detailItem = object
//                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
//                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
}

    // MARK: Table View
extension MasterViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cities.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let object = self.cities[indexPath.row]
        cell.textLabel!.text = object
        return cell
    }
    
}


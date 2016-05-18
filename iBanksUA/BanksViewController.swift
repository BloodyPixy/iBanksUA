//
//  BanksViewController.swift
//  iBanksUA
//
//  Created by Taras Pasichnyk on 5/18/16.
//  Copyright © 2016 Taras Pasichnyk. All rights reserved.
//

import UIKit

class BanksViewController: UITableViewController {

    var banks = [String]()
    
    var detailItem: String? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item
        if let detail = self.detailItem {
            mainMenuViewController.allJsonData { (result) in
                
                let allBanks = result["organizations"]
                
                for (_, object) in allBanks {
//                    if object["cityId"].stringValue == detail {
                        if !self.banks.contains(object["title"].stringValue) {
                            self.banks.append(object["title"].stringValue)
                        }
//                    }
                }
                
                self.tableView.reloadData()
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureView()
    }

}

// MARK: Segues
extension BanksViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = banks[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                //                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                //                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
}

// MARK: Table View
extension BanksViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.banks.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BankCell", forIndexPath: indexPath)
        
        let object = self.banks[indexPath.row]
        cell.textLabel!.text = object
        return cell
    }
    
}

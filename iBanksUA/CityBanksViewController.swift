//
//  CityBanksViewController.swift
//  iBanksUA
//
//  Created by Taras Pasichnyk on 5/31/16.
//  Copyright © 2016 Taras Pasichnyk. All rights reserved.
//

import UIKit
import SwiftyJSON

class CityBanksViewController: UITableViewController {
    
    var banks = [String]()
    var allBanks: JSON = []

    
    var detailItem: String? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        
        let master = MasterViewController()
        
        master.allCities({ (resultCities) in
            if let detail = self.detailItem {
                self.banks = [String]()
                master.allBanks({ (resultBanks) in
                    self.allBanks = resultBanks
                    for bank in resultBanks {
                        if bank.1[JsonConst.bank.cityId].stringValue == detail {
                            if !self.banks.contains(bank.1[JsonConst.bank.title].stringValue) {
                                self.banks.append(bank.1[JsonConst.bank.title].stringValue)
                            }
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.navigationItem.title = resultCities[self.detailItem!].stringValue
                        self.tableView.reloadData()
                    }
                })
            }
            
        })
    }
    
}

// MARK: Segue
extension CityBanksViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.kSegueShowCityBankDetailVC {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = self.banks[indexPath.row]
                let controller = segue.destinationViewController as! DetailViewController
                print("\(self.allBanks[indexPath.row]) \(object)")
                controller.detailItem = self.allBanks[indexPath.row]
            }
        }
    }
    
}

// MARK: Table View
extension CityBanksViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.banks.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.KeysConstants.kCityCellIdentifier, forIndexPath: indexPath)
        let object = self.banks[indexPath.row]
        cell.textLabel!.text = object
        return cell
    }
    
}

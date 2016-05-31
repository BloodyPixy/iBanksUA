//
//  ComparationViewController.swift
//  iBanksUA
//
//  Created by Taras Pasichnyk on 5/29/16.
//  Copyright © 2016 Taras Pasichnyk. All rights reserved.
//

import UIKit
import SwiftyJSON

class ComparationViewController: UITableViewController {
    
    var currencies = [Currency]()
    
    var detailItem: String? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        
        let master = MasterViewController()
        
        if let detail = self.detailItem {
            self.currencies = [Currency]()
            master.allBanks({ (result) in
                for bank in result {
                    if bank.1[JsonConst.bank.currencies, detail] != nil {
                        let newItem =
                            Currency(
                                newKey: detail,
                                newName: bank.1[JsonConst.bank.title].stringValue,
                                newSellPrice: bank.1[JsonConst.bank.currencies, detail, "ask"].stringValue,
                                newBuyPrice: bank.1[JsonConst.bank.currencies, detail, "bid"].stringValue)
                        self.currencies.append(newItem)
                    }
                }
            })
            
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
        
    }
    
}

// MARK: Table View
extension ComparationViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currencies.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.KeysConstants.kCurrencyCellIdentifier, forIndexPath: indexPath) as! CurrencyCell
        let object = self.currencies[indexPath.row]
        cell.currencyName.text = object.name
        cell.sellPrice.text = object.sellPrice
        cell.buyPrice.text = object.buyPrice
        return cell
    }
    
}
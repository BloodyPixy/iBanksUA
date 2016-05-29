//
//  MasterViewController.swift
//  iBanksUA
//
//  Created by Taras Pasichnyk on 5/28/16.
//  Copyright © 2016 Taras Pasichnyk. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import ARSLineProgress



class MasterViewController: UITableViewController {
    
    var banks = [String]()
    var onceToken: dispatch_once_t = 0
    
    var allBanks: JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        dispatch_once(&self.onceToken) {
            ARSLineProgress.show()
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), {
                self.allJsonData { (result) in
                    ARSLineProgress.showSuccess()
                    self.allBanks = result[JsonConst.organizations]
                    for (_, object) in self.allBanks {
                        if !self.banks.contains(object[JsonConst.bank.title].stringValue) {
                            self.banks.append(object[JsonConst.bank.title].stringValue)
                        }
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
}

// MARK: Table View
extension MasterViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.banks.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.KeysConstants.kBankCellIdentifier, forIndexPath: indexPath)
        let object = self.banks[indexPath.row]
        cell.textLabel!.text = object
        return cell
    }
    
}

// MARK: Segue
extension MasterViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.kSegueDetailVC {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = self.banks[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                print("\(self.allBanks[indexPath.row]) \(object)")
                controller.detailItem = self.allBanks[indexPath.row]
            }
        }
    }
    
}

//MARK: Networking
extension MasterViewController {
    
    func getDataFromUrlString(url: String, completion: (result: JSON) -> Void) {
        //TODO: ADD LOGIC FOR RE-DOWNLOADING
        // SAVE DATE TO USER DEFAULTS AND REDOWNLOAD EVERY NEW NON-WEEKEND DAY???
        
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.UrlConstants.kUrlToBanksJsonData)!)
        if let responseObject = NSURLCache.sharedURLCache().cachedResponseForRequest(request) {
            do {
                let nsJson = try NSJSONSerialization.JSONObjectWithData(responseObject.data, options: NSJSONReadingOptions.AllowFragments)
                completion(result: JSON(nsJson))
            } catch {
                print("[MainMenuViewController][getDataFromUrlString] - Error")
                completion(result: nil)
            }
        } else {
            Alamofire.request(request).validate().responseJSON { (response) in
                switch response.result {
                case .Success:
                    let cachedURLResponse = NSCachedURLResponse(response: response.response!, data: response.data!, userInfo: nil, storagePolicy: .Allowed)
                    NSURLCache.sharedURLCache().storeCachedResponse(cachedURLResponse, forRequest: response.request!)
                    print(response.request)  // original URL request
                    print(response.response) // URL response
                    let json = JSON(response.result.value!)
                    completion(result: json)
                    
                case .Failure(let error):
                    print(error)
                    completion(result: nil)
                }
            }
        }
    }
    
    func allJsonData(completion: (result: JSON) -> Void) {
        self.getDataFromUrlString(Constants.UrlConstants.kUrlToBanksJsonData) { (result) in
            completion(result: result)
        }
    }
    
    func allCurrencies(completion: (result: JSON) -> Void) {
        self.allJsonData { (result) in
            completion(result: result[JsonConst.currencies])
        }
    }
    
    func allCities(completion: (result: JSON) -> Void) {
        self.allJsonData { (result) in
            completion(result: result[JsonConst.cities])
        }
    }
    
    func allBanks(completion: (result: JSON) -> Void) {
        self.allJsonData { (result) in
            completion(result: result[JsonConst.organizations])
        }
    }
    
}

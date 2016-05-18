//
//  MainMenuViewController.swift
//  iBanksUA
//
//  Created by Taras Pasichnyk on 5/16/16.
//  Copyright © 2016 Taras Pasichnyk. All rights reserved.
//

import UIKit
import Alamofire
import ARSLineProgress
import SwiftyJSON

let mainMenuViewController = UIStoryboard(name: "Main", bundle: nil)
    .instantiateViewControllerWithIdentifier(Constants.KeysConstants.kMainMenuViewControllerIdentifier) as! MainMenuViewController

class MainMenuViewController: UIViewController {
    
    var serverResponse: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.getDataFromUrlString(Constants.UrlConstants.kUrlToBanksJsonData) { (result) in
//            print(result)
        }
    }
    
}

    // MARK: Main Menu Actions
extension MainMenuViewController {
    
    @IBAction func moveToCities(sender: UIButton) {
        self.dismissViewControllerAnimated(true) { 
            
        }
    }
}

// MARK: Bank Download
extension MainMenuViewController {
    
    func getDataFromUrlString(url: String, completion: (result: JSON) -> Void) {
        ARSLineProgress.show()
        //TODO: ADD LOGIC FOR RE-DOWNLOADING
        
        // SAVE DATE TO USER DEFAULTS AND REDOWNLOAD EVERY NEW NON-WEEKEND DAY???
        
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.UrlConstants.kUrlToBanksJsonData)!)
        if let responseObject = NSURLCache.sharedURLCache().cachedResponseForRequest(request) {
            do {
                let nsJson = try NSJSONSerialization.JSONObjectWithData(responseObject.data, options: NSJSONReadingOptions.AllowFragments)
                completion(result: JSON(nsJson))
                ARSLineProgress.showSuccess()
            } catch {
                print("[MainMenuViewController][getDataFromUrlString] - Error")
                completion(result: nil)
                ARSLineProgress.showFail()
            }
        } else {
            Alamofire.request(request)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .Success:
                        let cachedURLResponse = NSCachedURLResponse(response: response.response!, data: response.data!, userInfo: nil, storagePolicy: .Allowed)
                        NSURLCache.sharedURLCache().storeCachedResponse(cachedURLResponse, forRequest: response.request!)
                        print(response.request)  // original URL request
                        print(response.response) // URL response
                        let json = JSON(response.result.value!)
                        completion(result: json)
                        ARSLineProgress.showSuccess()
                    case .Failure(let error):
                        print(error)
                        completion(result: nil)
                        ARSLineProgress.showFail()
                    }
            }
            
        }
        
    }
    
    func allJsonData(completion: (result: JSON) -> Void) {
        self.getDataFromUrlString(Constants.UrlConstants.kUrlToBanksJsonData) { (result) in
            completion(result: result)
        }
    }
    
}

// MARK: Helpers
extension MainMenuViewController {
    
    func showMainMenuOnController(controller: UIViewController?) {
        controller!.presentViewController(mainMenuViewController, animated: false, completion: nil)
    }
    
}

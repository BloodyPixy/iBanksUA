//
//  Bank.swift
//  iBanksUA
//
//  Created by Taras Pasichnyk on 5/28/16.
//  Copyright © 2016 Taras Pasichnyk. All rights reserved.
//

import Foundation
import SwiftyJSON

class Bank {
    
    var address: String?
    var cityId: String?
    var currencies: [Currency]?
    var link: String?
    var phone: String?
    var title: String?
    
    init(dict: NSDictionary){
        address = dict["address"] as? String
        cityId = dict["cityId"] as? String
        currencies = dict["currencies"] as? [Currency]
        link = dict["link"] as? String
        phone = dict["phone"] as? String
        title = dict["title"] as? String
    }

}

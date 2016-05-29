//
//  Currency.swift
//  iBanksUA
//
//  Created by Taras Pasichnyk on 5/28/16.
//  Copyright © 2016 Taras Pasichnyk. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class Currency {
    
    var name: String?
    var sellPrice: String?
    var buyPrice: String?
    var key: String?
    
    init() {
        key = ""
        name = ""
        sellPrice = ""
        buyPrice = ""
    }
    
    init(newKey: String?, newName: String?, newSellPrice: String?, newBuyPrice: String?) {
        key = newKey
        name = newName
        sellPrice = newSellPrice
        buyPrice = newBuyPrice
    }
    
}

//
//  Constants.swift
//  iBanksUA
//
//  Created by Taras Pasichnyk on 5/28/16.
//  Copyright © 2016 Taras Pasichnyk. All rights reserved.
//

import Foundation

struct Constants {
    
    static let kSegueDetailVC = "showDetail"
    static let kSegueShowCityBanksVC = "showCityBanks"
    static let kSegueShowCityBankDetailVC = "showCityBankDetail"
    static let kSegueShowCurrencyBanksVC = "showCurrencyBanks"
    static let kCompareRates = "compareRates"
    
    struct KeysConstants {
        static let kAllJsonData = "kAllJsonData"
        static let kCurrencyCellIdentifier = "CurrencyCell"
        static let kBankCellIdentifier = "BankCell"
        static let kCityCellIdentifier = "CityCell"
//        static let kCompareCellIdentifier = "CompareCell"
    }
    
    struct UrlConstants {
        static let kUrlToBanksJsonData = "http://resources.finance.ua/ua/public/currency-cash.json"
    }
    
}

struct JsonConst {
    
    static let organizations = "organizations"
    static let currencies = "currencies"
    static let cities = "cities"
    
    struct bank {
        static let title = "title"
        static let cityId = "cityId"
        static let currencies = "currencies"
        static let link = "link"
        static let phone = "phone"
        static let address = "address"
    }
    
}
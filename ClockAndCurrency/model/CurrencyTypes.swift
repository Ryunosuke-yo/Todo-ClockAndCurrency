//
//  CurrencyTypes.swift
//  ClockAndCurrency
//
//  Created by Ryunosuke Yokokawa on 2023-08-27.
//

import Foundation

struct CurrecnyList: Codable {
    let results : [String : EachCurrencyInList]
}


struct EachCurrencyInList : Codable {
    let currencyName: String
    let currencySymbol: String?
    let id: String
}


//
//  CurrencyTypes.swift
//  ClockAndCurrency
//
//  Created by Ryunosuke Yokokawa on 2023-08-27.
//

import Foundation

struct CurrecnyList: Codable {
    let data : [String : EachCurrencyInList]
}


struct EachCurrencyInList : Codable {
    let symbol: String
    let name: String
    let symbol_native: String
    let decimal_digits: Int
    let rounding: Int
    let code: String
    let name_plural: String
}

struct HistoricalRateResult: Codable {
    let data: [String: [String : Double]]
}

struct CurrencyRateResult: Codable {
    let meta: [String: String]?
    let data : [String: Double]
}




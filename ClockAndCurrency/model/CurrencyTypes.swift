//
//  CurrencyTypes.swift
//  ClockAndCurrency
//
//  Created by Ryunosuke Yokokawa on 2023-08-27.
//

import Foundation

struct CurrecnyList: Codable {
    let success: Bool
    let symbols : [String : String]
   
}

struct ConvertResult: Codable {
    let success: Bool
    let query : [ConvertQuery]
    let info : [ConvertInfo]
    let historical : String
    let date : String
    let result: Double
}

struct ConvertQuery: Codable {
    let from : String
    let to : String
    let ammount: Double
    
}

struct ConvertInfo: Codable {
    let timestamp: Double
    let rate : Double
}

enum CurrecnyAPIError: Error {
    case invalidUrl
    case invalidResponse
    case decodeError
}

enum CurrecnyLoading {
    case loading
    case completed
    case error
}

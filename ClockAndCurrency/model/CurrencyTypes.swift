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
    struct Query: Codable {
        let from: String
        let to: String
        let amount: Double
    }
    
    struct Info: Codable {
        let timestamp: Int
        let rate: Double
    }
    
    let success: Bool
    let query: Query
    let info: Info
    let date: String
    let result: Double
}


struct LatestCurrencyResult: Codable {
    let success: Bool
    let base : String
    let timestamp: String
    let date: String
    let rates: [String: Double]
}


enum APIError: Error {
    case invalidUrl
    case invalidResponse
    case decodeError
}

enum CurrecnyLoading {
    case loading
    case completed
    case error
}

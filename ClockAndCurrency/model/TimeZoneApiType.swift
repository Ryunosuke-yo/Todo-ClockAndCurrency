//
//  TimeZoneApiType.swift
//  ClockAndCurrency
//
//  Created by Ryunosuke Yokokawa on 2023-08-30.
//

import Foundation


struct ConversionApiResult: Codable {
    
    let fromTimezone: String
    let fromDateTime: String
    let toTimeZone: String
    let conversionResult: ConversionResult
    
    struct ConversionResult : Codable {
            let year: Int
            let month: Int
            let day: Int
            let hour: Int
            let minute: Int
            let seconds: Int
            let milliSeconds: Int
            let dateTime: String
            let date: String
            let time: String
            let timeZone: String
            let dstActive: Bool
    }
    
}

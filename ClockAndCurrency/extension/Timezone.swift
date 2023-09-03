//
//  Timezone.swift
//  ClockAndCurrency
//
//  Created by Ryunosuke Yokokawa on 2023-08-30.
//

import Foundation

extension TimeZone {
    static let allTimeZonesIdentifiers = TimeZone.knownTimeZoneIdentifiers
    static let allCities = allTimeZonesIdentifiers.compactMap {
        identifier in identifier.split(separator: "/").last?.replacingOccurrences(of: "_", with: " ")
    }
    static let unknown = "Unknown"
}

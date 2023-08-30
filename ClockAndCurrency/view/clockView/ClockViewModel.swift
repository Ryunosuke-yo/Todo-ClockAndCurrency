//
//  ClockViewModel.swift
//  ClockAndCurrency
//
//  Created by Ryunosuke Yokokawa on 2023-08-30.
//

import Foundation


extension ClockView {
    @MainActor
    class ClockViewModel : ObservableObject {
        @Published var segmentValue = 0
    }
}

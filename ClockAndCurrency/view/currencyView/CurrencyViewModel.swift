//
//  CurrencyViewModel.swift
//  ClockAndCurrency
//
//  Created by Ryunosuke Yokokawa on 2023-08-23.
//

import Foundation

extension CurrencyView {
    @MainActor
    class CurrencyViewModel: ObservableObject {
        @Published var showCurrecnyListModal = false
        @Published var isLoading = CurrecnyLoading.loading
        @Published var currencyList = [String : String]()
    }
}

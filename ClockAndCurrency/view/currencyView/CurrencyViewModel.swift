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
        @Published var isLoading = ApiLoading.loading
        @Published var currencyList = [String : String]()
        @Published var currecnySearchValue = ""
        @Published var showListResult = true
        @Published var selectedValue = SelectedValue.main
      
        
        
        func doesListInclude(_ charactor: String)-> Bool {
            var inc = false
            for c in currencyList {
                if c.key.contains(charactor) {
                    inc = true
                   
                }
            }
            return inc
        }
    }
}


enum SelectedValue {
    case main
    case second
}

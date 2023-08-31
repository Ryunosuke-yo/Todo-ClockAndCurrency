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
        @Published var selectedDateAndTime = Date()
        @Published var showCityListModal = false
        @Published var citySearchValue = ""
        @Published var mainCity = ""
        @Published var secondCity = ""
        @Published var selectedCity = SelectedCity.main
        @Published var timeZoneList = [String]()
        
        func doesListInclude(_ value: String)-> Bool {
            var include = false
            for city in TimeZone.allCities {
                if city.contains(value) {
                    include = true
                }
               
            }
            
            return include
        }
        
        func onTapCity(value: String)-> Void {
            if selectedCity == .main {
                mainCity = value
            } else if selectedCity == .second {
                secondCity = value
            }
            
            showCityListModal.toggle()
        }
        
        
    }
}

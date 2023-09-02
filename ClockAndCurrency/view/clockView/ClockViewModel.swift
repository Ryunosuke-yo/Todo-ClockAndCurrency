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
        @Published var loadingState = ApiLoading.completed
        @Published var mainCityDateTimeToDisplay = ""
        @Published var secondCityDateTimeToDisplay = ""
        @Published var worldClockDate = Date.now
        
        func doesListInclude(_ value: String)-> Bool {
            var include = false
            for city in timeZoneList {
                if String(city.split(separator: "/").last ?? "").contains(value) {
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
        
        func convertDateTime()-> Void {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateTime = formatter.string(from: selectedDateAndTime)
            TimeZoneApiClient().converTimeZone(from: mainCity, to: secondCity, dateTime:dateTime) {
                res in
                let inputFormatter = DateFormatter()
                inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                guard let date = inputFormatter.date(from: res.conversionResult.dateTime) else {
                    return
                }
                
                let outputDateFromatter = DateFormatter()
                outputDateFromatter.locale = Locale(identifier: Locale.current.identifier)
                outputDateFromatter.dateFormat = "h:mm a, dd, MMM, yyyy"
                let mainCityOutput = outputDateFromatter.string(from: self.selectedDateAndTime)
                let secondCityOutput = outputDateFromatter.string(from: date)
                print(mainCityOutput)
                self.mainCityDateTimeToDisplay = mainCityOutput
                self.secondCityDateTimeToDisplay = secondCityOutput
            }
        }
        
        func getWorldClockTime(date: Date, timeZone: TimeZone)-> String {
            let formatter = DateFormatter()
            formatter.timeZone = timeZone
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        }
        
        func getCityNamefromTimeZone(timeZoneIdentifiers: String)-> String {
            guard let city = timeZoneIdentifiers.split(separator: "/").last else {
                return "Unknown"
            }
            
            return city.replacingOccurrences(of: "_", with: " ")
        }
    }
}

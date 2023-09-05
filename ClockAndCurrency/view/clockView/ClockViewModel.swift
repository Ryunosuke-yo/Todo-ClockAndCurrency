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
        @Published var showWorldClockLList = false
        
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
                return TimeZone.unknown
            }
            
            return city.replacingOccurrences(of: "_", with: " ")
        }
        
        func getTimeWithTimeZone(identifier: String, date: Date)-> String {
            let timeZone = TimeZone(identifier: identifier)
            
            let formatter = DateFormatter()
            formatter.timeZone = timeZone
            formatter.dateFormat = "h:mm a"
            formatter.amSymbol = "AM"
            formatter.pmSymbol = "PM"
            
            let dateString = formatter.string(from: date)
            
            return dateString
        }
        
        func getTodayOrTommorowOrYesterday(identifier: String, date: Date)-> String {
            guard let days = calculateDateGap(identifier: identifier, date: date) else {
                return "Unknown"
            }
            
            if  days.dayInLocal < days.dayInTimeZone {
                return "Tomorrow"
            } else if  days.dayInLocal > days.dayInTimeZone {
                return "Yesterday"
            } else if  days.dayInLocal == days.dayInTimeZone {
                return "Today"
            }
           
            
           return "Unkonwn"
        }
        
        func getTimeGap(identifier: String, date: Date)-> Int?{
            guard let days = calculateDateGap(identifier: identifier, date: date) else {
                return nil
            }
            
          
            
            return days.timeGap
        }
        
        
        private func calculateDateGap(identifier: String, date: Date)-> LocalAndTimeZoneDay? {
            guard let timeZone = TimeZone(identifier: identifier) else {
                return nil
            }
            let calendar = Calendar.current
            let dateCompInLocal = calendar.dateComponents(in: TimeZone.current, from: date)
            let dateCompInTimeZone = calendar.dateComponents(in: timeZone, from: date)
            let localDay = dateCompInLocal.day
            let timeZoneDay = dateCompInTimeZone.day
            let localHour = dateCompInLocal.hour
            let timeZoneHour = dateCompInTimeZone.hour
            
            guard let dayInLocal = localDay, let dayInTimeZone = timeZoneDay, let hrInLocal = localHour, let hrInTimeZone = timeZoneHour else {
                return nil
            }
            
            var timeGap: Int
            
             if dayInLocal < dayInTimeZone && hrInLocal > hrInTimeZone {
                 let gap = hrInLocal - hrInTimeZone
                 
                 timeGap = 24 - gap
            } else {
                timeGap = hrInTimeZone - hrInLocal
            }
            
            
            
          
            
            return LocalAndTimeZoneDay(dayInLocal: dayInLocal, dayInTimeZone: dayInTimeZone, timeGap: timeGap)
        }
    }
}


struct LocalAndTimeZoneDay {
    let dayInLocal: Int
    let dayInTimeZone: Int
    let timeGap: Int
}

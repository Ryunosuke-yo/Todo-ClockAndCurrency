//
//  TimeZoneApiClient.swift
//  ClockAndCurrency
//
//  Created by Ryunosuke Yokokawa on 2023-08-30.
//

import Foundation
import Alamofire

struct TimeZoneApiClient {
    let baseUrl = "https://timeapi.io/"
    
    
    func getAllTimeZone(onCallComplated: @escaping ()-> Void) {
        let url = baseUrl + "/api/TimeZone/AvailableTimeZones"
        getResult([String].self, url: url) { result in
            onCallComplated()
        }
    }
    
    func getResult<T:Decodable>(_ type: T.Type, url:String, onCallCompleted: @escaping (T)-> Void)-> Void {
        AF.request(url).response { response in
            guard let res = response.response, let data = response.data else {
                return
            }
            if res.statusCode != 200  {
                print(res.description)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let decoded =  try decoder.decode(T.self, from: data)
               
                onCallCompleted(decoded)
            } catch {
                print(res.description,"decode error")
                
            }
            
        }
        
        
    }
    
}

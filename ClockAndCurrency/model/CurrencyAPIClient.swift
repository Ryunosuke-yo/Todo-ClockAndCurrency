//
//  CurrencyAPIClient.swift
//  ClockAndCurrency
//
//  Created by Ryunosuke Yokokawa on 2023-08-24.
//

import Foundation
import Alamofire

class CurrencyAPIClinet {
    static let shared = CurrencyAPIClinet()
    
    private let baseURL = "https://free.currconv.com"
    private let freeCurrencyBaseUrl = "https://api.freecurrencyapi.com/v1/"
    
    private let apiKeyParams = [
        "apiKey" : currecnyApiKey
    ]
    
    private let freeCurrencyApiKeyParam = [
        "apikey" : freeCurrencyApikey
    ]

    
    
    func getCurrencyList (onCallCompleted: @escaping (CurrecnyList)-> Void, onError: @escaping (AFError)-> Void) -> Void {
        let url = freeCurrencyBaseUrl + "currencies"
        
        AF.request(url, parameters: freeCurrencyApiKeyParam)
            .responseDecodable(of: CurrecnyList.self) {
            res in

            switch res.result {
            case .success(let res) :
                onCallCompleted(res)
            case .failure(let error):
                onError(error)
                print(error)
            }
        }
        
    
    }
    
    
    func getCurrentcyRate (from: String, to: String, onCallCompleted: @escaping ((CurrencyRateResult) -> Void), onError: @escaping (AFError)-> Void) -> Void {
        let url = freeCurrencyBaseUrl + "latest"
        var rateParameters = [
            "base_currency" : from,
            "currencies" : to,
        ]
        
        rateParameters.merge(freeCurrencyApiKeyParam) {
            (current, _) in
            current
        }
        
        AF.request(url, parameters: rateParameters).responseDecodable(of: CurrencyRateResult.self) {
            res in
            switch res.result {
            case .success(let res):
                onCallCompleted(res)
            case .failure(let error):
                onError(error)
                print(error.localizedDescription)
            }
        }
        
    }
    
    func convertCurrency(amount: Double, rate: Double)-> Double {
        amount * rate
    }
    
  
}





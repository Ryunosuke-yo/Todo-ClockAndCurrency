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
    
    private let apiKeyParams = [
        "apiKey" : currecnyApiKey
    ]

    
    
    func getCurrencyList (onCallCompleted: @escaping (CurrecnyList)-> Void, onError: @escaping (AFError)-> Void) -> Void {
        let url = baseURL + "/api/v7/currencies"
        
        AF.request(url, parameters: apiKeyParams)
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
    
    
    func getCurrentcyRate (from: String, to: String, onCallCompleted: @escaping (([String: Double]) -> Void), onError: @escaping (AFError)-> Void) -> Void {
        let url = baseURL + "/api/v7/convert"
        var rateParameters = [
            "q" : "\(from)_\(to)",
            "compact" : "ultra",
        ]
        
        rateParameters.merge(apiKeyParams) {
            (current, _) in
            current
        }
        
        AF.request(url, parameters: rateParameters).responseDecodable(of: [String: Double].self) {
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





//
//  CurrencyAPIClient.swift
//  ClockAndCurrency
//
//  Created by Ryunosuke Yokokawa on 2023-08-24.
//

import Foundation

class CurrencyAPIClinet {
    static let shared = CurrencyAPIClinet()
    
    private let baseURL = URL(string :"http://api.exchangeratesapi.io/v1/")
    
    private let apiKeyQuery = [
        URLQueryItem(name: "access_key", value: "")
    ]
    
    
    func getCurrencyList () async throws -> CurrecnyList {
        guard let baseUrl = baseURL else {
            print("Error on getCurrencyList_ base url")
            throw CurrecnyAPIError.invalidUrl
        }
        
        
        
        guard var urlComponemts = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true) else {
            print("Error on getCurrencyList_ url")
            throw CurrecnyAPIError.invalidUrl
        }
        urlComponemts.path = "/symbols"
        urlComponemts.queryItems = apiKeyQuery
        
        guard let finalUrl = urlComponemts.url else {
            print("Error on getCurrencyList_ final url")
            throw CurrecnyAPIError.invalidUrl
        }
        
        
      
        let (data, response) = try await URLSession.shared.data(from: finalUrl)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
           
            throw CurrecnyAPIError.invalidResponse
        }
        
        
        
        do {
            
            let decoder = JSONDecoder()
            let list = try decoder.decode(CurrecnyList.self, from: data)
            
            return list
        } catch {
            throw CurrecnyAPIError.decodeError
        }
    }
}


struct CurrecnyList: Codable {
    let success: Bool
    let symbols : [String : String]
   
}

enum CurrecnyAPIError: Error {
    case invalidUrl
    case invalidResponse
    case decodeError
}

enum CurrecnyLoading {
    case loading
    case completed
    case error
}


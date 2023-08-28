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
        URLQueryItem(name: "access_key", value: CurrecnyApiKey)
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
        
        
      
        let list = try await getResult(CurrecnyList.self, finalUrl: finalUrl)
        
        return list
    }
    
    
    func convertCurrecnt (from: String, to: String, ammount: String) async throws  -> ConvertResult {
        guard let baseUrl = baseURL else {
            print("Error on convertCurrecny base url")
            throw CurrecnyAPIError.invalidUrl
        }
        
        guard var urlComponemts = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true) else {
            print("Error on convertCurrecny url")
            throw CurrecnyAPIError.invalidUrl
        }
        
        let convertQuery = [
            URLQueryItem(name: "from", value: from),
            URLQueryItem(name: "to", value: to),
            URLQueryItem(name: "amount", value: ammount)
        ]
        urlComponemts.path = "/convert"
        urlComponemts.queryItems = apiKeyQuery
        urlComponemts.queryItems = convertQuery
        
        guard let finalUrl = urlComponemts.url else {
            print("Error on convert_ final url")
            throw CurrecnyAPIError.invalidUrl
        }
        
         let res = try await getResult(ConvertResult.self, finalUrl: finalUrl)
        
        return res
        
    }
    
    func getResult<Result: Codable> (_ t: Result.Type, finalUrl:URL) async throws -> Result {
        let (data, response) = try await URLSession.shared.data(from: finalUrl)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
           
            throw CurrecnyAPIError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(Result.self, from: data)
            
            return result
        } catch {
            throw CurrecnyAPIError.decodeError
        }
    }
}





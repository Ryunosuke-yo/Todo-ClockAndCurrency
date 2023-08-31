//
//  CurrencyAPIClient.swift
//  ClockAndCurrency
//
//  Created by Ryunosuke Yokokawa on 2023-08-24.
//

import Foundation


class CurrencyAPIClinet {
    static let shared = CurrencyAPIClinet()
    
    private let baseURL = URL(string: "http://api.exchangeratesapi.io")
    
    private let apiKeyQuery = URLQueryItem(name: "access_key", value: CurrecnyApiKey)
    
    
    func getCurrencyList () async throws -> CurrecnyList {
        guard let baseUrl = baseURL else {
            print("Error on list ")
            throw APIError.invalidUrl
        }
        
        guard var urlComponemts = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true) else {
            print("Error on getCurrencyList_ url")
            throw APIError.invalidUrl
        }
        let params = [
            apiKeyQuery,
        ]
        urlComponemts.path = "/v1/symbols"
        urlComponemts.queryItems = params
        
        guard let finalUrl = urlComponemts.url else {
            print("Error on getCurrencyList_ final url")
            throw APIError.invalidUrl
        }
        
        
        
        let list = try await getResult(CurrecnyList.self, finalUrl: finalUrl)
        
        return list
        
        
    }
    
    
    func convertCurrency (from: String, to: String, amount: String) async throws  -> ConvertResult {
        guard let baseUrl = baseURL else {
            print("Error on convertCurrecny base url")
            throw APIError.invalidUrl
        }
        
        guard var urlComponemts = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true) else {
            print("Error on convertCurrecny url")
            throw APIError.invalidUrl
        }
        
        let convertQuery = [
            apiKeyQuery,
            URLQueryItem(name: "from", value: from),
            URLQueryItem(name: "to", value: to),
            URLQueryItem(name: "amount", value: amount),
        ]
        urlComponemts.path = "/convert"
        urlComponemts.queryItems = convertQuery
        
        guard let finalUrl = urlComponemts.url else {
            print("Error on convert_ final url")
            throw APIError.invalidUrl
        }
        let res = try await getResult(ConvertResult.self, finalUrl: finalUrl)

        return res
        
    }
    
    func getResult<Result: Codable> (_ t: Result.Type, finalUrl:URL) async throws -> Result {
        let (data, response) = try await URLSession.shared.data(from: finalUrl)
        print(response, "result")
        print(data)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(Result.self, from: data)

            return result
        } catch {
            print(error.localizedDescription)
            throw APIError.decodeError
        }
    }
    
    func getLatestRate(base: String, symbols: [String]) async throws -> LatestCurrencyResult {
        guard let baseUrl = baseURL else {
            print("Error on latest url")
            throw APIError.invalidUrl
        }
        
        guard var urlComponemts = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true) else {
            print("Error on latest url")
            throw APIError.invalidUrl
        }
        var symbolsValue: String = ""
        
        for symbol in symbols {
            symbolsValue += "\(symbol),"
        }
        
        
        let params = [
            apiKeyQuery,
            URLQueryItem(name: "base", value: base),
            URLQueryItem(name: "symbols", value: symbolsValue)
        ]
        
        
        urlComponemts.path = "/v1/latest"
        urlComponemts.queryItems = params
        
        
        guard let finalUrl = urlComponemts.url else {
            print("Error on latest_ final url")
            throw APIError.invalidUrl
        }
        let res = try await getResult(LatestCurrencyResult.self, finalUrl: finalUrl)
        print(res)
        return res
        
    }
}





//
//  CurrencyManager.swift
//  Currency Converter
//
//  Created by Kento Nambara on 2020/11/03.
//  Copyright © 2020 Kento Nambara. All rights reserved.
//

import Foundation

protocol CurrencyManagerDelegate {
    func didUpdatePrice(_ currencyManager: CurrencyManager, price: String, inputCurrency: String, outputCurrency: String) // by convention include identity of object that calls the delegate method
    func didFailWithError(_ currencyManager: CurrencyManager, error: Error)
}

struct CurrencyManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate"
    let apiKey = "38F58BA6-9DB0-409A-AB6A-20784DDE77EF"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CurrencyManagerDelegate?
    
    func getCurrencyPrice(value: String, from currency1: String, to currency2: String) {
        if let url = URL(string: "\(baseURL)/\(currency1)/\(currency2)?apikey=\(apiKey)") {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(self, error: error!)
                    return
                }
                if let safeData = data {
                    if let rate = self.parseJSON(data: safeData) {
                        let result = self.calculateValue(value, rate)
                        if result != nil {
                            self.delegate?.didUpdatePrice(self, price: result!, inputCurrency: currency1, outputCurrency: currency2)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    func calculateValue(_ value: String, _ price: String) -> String? {
        if let inputValue = Double(value), let currencyPrice = Double(price) {
            let result = inputValue * currencyPrice
            print(String(result))
            return String(format: "%.2f", result)
        }
        return nil
    }
    
    func parseJSON(data: Data) -> String? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CurrencyData.self, from: data) //.self to reference the type and not object
            let rate = String(decodedData.rate)
            return rate
        } catch {
            // raise error
            self.delegate?.didFailWithError(self, error: error)
            return nil
        }
    }
    
}

//
//  ViewController.swift
//  Currency Converter
//
//  Created by Kento Nambara on 2020/11/02.
//  Copyright © 2020 Kento Nambara. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var inputCurrency: UILabel!
    @IBOutlet weak var outputLabel: UILabel!
    @IBOutlet weak var outputCurrency: UILabel!
    
    var currencyManager = CurrencyManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTextField.delegate = self
        currencyManager.delegate = self
    }
    
}

//MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        //check if non-negative and float
        if let safeText = textField.text {
            if !safeText.isNumber {
                return false
            } else {
                let value = Double(safeText)!
                if value < 0 {
                    return false
                }
                return true
            }
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //call api
        if let inputValue = inputTextField.text, let inputCurrency = inputCurrency.text, let outputCurrency = outputCurrency.text  {
            currencyManager.getCurrencyPrice(value: inputValue, from: inputCurrency, to: outputCurrency)
        }
    }
}

//MARK: - CurrencyManagerdDelegate

extension ViewController: CurrencyManagerDelegate {
    func didUpdatePrice(_ currencyManager: CurrencyManager, price: String, inputCurrency: String, outputCurrency: String) {
        DispatchQueue.main.async {
            self.inputCurrency.text = inputCurrency
            self.outputCurrency.text = outputCurrency
            self.outputLabel.text = price
        }
    }
    
    func didFailWithError(_ currencyManager: CurrencyManager, error: Error) {
        //show popup
    }
    
    
}


//MARK: - String extension

extension String  {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}

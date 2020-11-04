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
    
    @IBOutlet weak var currencyPicker: UIPickerView!
    var currencyManager = CurrencyManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTextField.delegate = self
        currencyPicker.dataSource = self
        currencyPicker.delegate = self
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

//MARK: - UIPickerViewDelegate, UIDataSource

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int { // how many columns
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyManager.currencyArray.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyManager.currencyArray[row]
    }
    
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {

        let string = currencyManager.currencyArray[row]
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let currency = currencyManager.currencyArray[row]
        if component == 0 {
            if inputTextField.text != nil && inputTextField.text != "" {
                currencyManager.getCurrencyPrice(value: inputTextField.text!, from: currency, to: outputCurrency.text!)
            } else {
                inputCurrency.text = currency
            }
        } else {
            if inputTextField.text != nil && inputTextField.text != "" {
                currencyManager.getCurrencyPrice(value: inputTextField.text!, from: inputCurrency.text!, to: currency)
            } else {
                outputCurrency.text = currency
            }
        }
    }
}

//MARK: - String extension

extension String  {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}

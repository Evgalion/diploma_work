//
//  RequestCreateViewController.swift
//  FarmerApp
//
//  Created by Женя on 10.05.2023.
//

import Foundation
import UIKit
import GRDB


class RequestCreateViewController : UIViewController, UITextFieldDelegate
{
    
    
    @IBOutlet weak var incomeLabel: UILabel!
    

    @IBOutlet weak var errorLabel: UILabel!
    
    
    public var dbQueue: DatabaseQueue?
    @IBOutlet weak var typePickerView: UIPickerView!
    
    @IBOutlet weak var qualityPickerView: UIPickerView!
    
    
    @IBOutlet weak var weightTypePickerVIew: UIPickerView!
    
    
    @IBOutlet weak var priceTypeViewPicker: UIPickerView!
    
    @IBOutlet weak var weightTextField: UITextField!
    
    @IBOutlet weak var priceTextField: UITextField!
    
    
    @IBOutlet weak var traiderIDLabel: UILabel!
    
    @IBOutlet weak var sliderTraderId: UISlider!
    
    var farmerID:Int = 0
    var selectedTypeProduct:String?
    var selectedQuality:Int?
    var selectedStatus:String?
    var selectedTypeWeight: String?
    var selectedTypePrice: String?
    
    var TraderId:Int?
    
    
    var TraderIDCount: Int?
    
    var currentDate:String?
    let formatter = DateFormatter()
    
    
   
    
    // Определение массивов значений для UIPickerView
    let values_type = PickerValues.values_type
    let values_quality = PickerValues.values_quality
    let values_status = PickerValues.values_status
    let values_type_weight = PickerValues.values_type_weight
    let values_type_price = PickerValues.values_type_price
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        typePickerView.dataSource = self
        qualityPickerView.dataSource = self
        weightTypePickerVIew.dataSource = self
        priceTypeViewPicker.dataSource = self
        
        typePickerView.delegate = self
        qualityPickerView.delegate = self
        weightTypePickerVIew.delegate = self
        priceTypeViewPicker.delegate = self
        
        weightTextField.delegate = self
        priceTextField.delegate = self
        
        formatter.dateFormat = "dd.MM.yyyy"
        currentDate = formatter.string(from: Date())
        
        // Задаём значения по умолчанию
        selectedTypeProduct = values_type[0]
        selectedQuality = Int(values_quality[0])
        selectedStatus = values_status[0]
        selectedTypeWeight = values_type_weight[0]
        selectedTypePrice = values_type_price[0]
        
        sliderTraderId.maximumValue = Float(TraderIDCount!)
        sliderTraderId.minimumValue = 0
        
        TraderId = TraderIDCount
        
    }
    
    
    
    @IBAction func changedTraderID(_ sender: UISlider) {
        
        TraderId = Int(sender.value)
        traiderIDLabel.text = String(TraderId!)
    }
    
    
    
    
    
    
    @IBAction func addReqButtonPressed(_ sender: UIButton) {
        
     
        

            if (!checkTextFields())
            {
                errorLabel.text = "Не все поля были заполненны"
            }
            else
            {
                var newRequest: Frequest = Frequest(id: 0, farmer_id: farmerID, product: selectedTypeProduct!, quality: selectedQuality!, weight: Double(weightTextField.text!)!,type_weight: selectedTypeWeight! , price: Int(priceTextField.text!)!, type_price: selectedTypePrice!, date_created: currentDate!,status: selectedStatus!, Traderid: TraderId!)
                
                
                do{
                    try dbQueue?.write { db in
                        try db.execute(sql: "INSERT INTO FRequest (farmer_id, product, quality, weight,type_weight, price,type_price, date_created,status,Traderid) VALUES (?,?,?,?,?,?,?,?,?,?)", arguments: [newRequest.farmer_id, newRequest.product, newRequest.quality, newRequest.weight, newRequest.type_weight, newRequest.price,  newRequest.type_price,newRequest.date_created,newRequest.status, newRequest.Traderid])
                    }
            }
                catch {
                    print("Произошла неизвестная ошибка: \(error)")
                }
                
                self.dismiss(animated: true)
            }

    }
    
    func checkTextFields() -> Bool
    {
        var flag:Bool = true
        
        if(weightTextField.text! == "" || priceTextField.text! == "")
        {
            flag = false
        }

        return flag
        
    }
    
    
    func TextsFieldChanged()
    {
        incomeLabel.text = "Заработок: "
        
        if(checkTextFields())
        {
            
            if let weightText = weightTextField.text, let priceText = priceTextField.text, let selectedType = selectedTypePrice {
                if let weight = Double(weightText), let price = Double(priceText) {
                    let income = weight * price
                    let incomeText = String(income) + " " + selectedType
                    incomeLabel.text! += incomeText
                }
            }
        }        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        TextsFieldChanged()
        return true
    }
    
    
    
}

extension RequestCreateViewController:UIPickerViewDataSource
{
   
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        
    switch pickerView {
        case typePickerView:
                return values_type.count
        case qualityPickerView:
                return values_quality.count
        case weightTypePickerVIew:
                return values_type_weight.count
        case priceTypeViewPicker:
                return values_type_price.count
            
        default:
               return 0
           }
    }
    
    
    
}

extension RequestCreateViewController: UIPickerViewDelegate
{
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView {
        case typePickerView:
            return values_type[row]
        case qualityPickerView:
            return values_quality[row]
        case weightTypePickerVIew:
            return values_type_weight[row]
        case priceTypeViewPicker:
            return values_type_price[row]
            
        default:
            return ""
        }
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch pickerView {
        case typePickerView:
            selectedTypeProduct = values_type[row]
        case qualityPickerView:
            selectedQuality = Int(values_quality[row])
        case weightTypePickerVIew:
            selectedTypeWeight = values_type_weight[row]
        case priceTypeViewPicker:
            selectedTypePrice = values_type_price[row]
        default:
            print("error")
        }
        
    }
}

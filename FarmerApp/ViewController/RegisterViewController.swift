//
//  RegisterViewController.swift
//  FarmerApp
//
//  Created by Женя on 10.05.2023.
//

import Foundation
import UIKit
import GRDB

class RegisterViewController: UIViewController {

    
    public var dbQueue: DatabaseQueue?
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var secondNameTextField: UITextField!
    
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBOutlet weak var addressTextField: UITextField!
    
    
    @IBOutlet weak var farmSizeTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        if (!checkTextFields())
        {
            errorLabel.text = "Не все поля были заполненны"
        }
        else
        {
            var myFarmer:Farmer = Farmer(id: 0, first_name: nameTextField.text!, second_name: secondNameTextField.text!, phone_number: phoneNumberTextField.text!, password: passwordTextField.text!, main_address: addressTextField.text!, farm_size: Int(farmSizeTextField.text!)!)
            
            try? dbQueue?.write { db in
                try db.execute(sql: "INSERT INTO Farmer (first_name, second_name, phone_number, password, main_address, farm_size) VALUES (?, ?, ?,?,?,?)", arguments: [myFarmer.first_name,myFarmer.second_name,myFarmer.phone_number,myFarmer.password,myFarmer.main_address,myFarmer.farm_size])
            }
            
            self.dismiss(animated: true)
        }
        
    }
    
    
    func checkTextFields() -> Bool
    {
        var flag:Bool = true
        
        if(nameTextField.text! == "" || secondNameTextField.text! == "" || phoneNumberTextField.text! == "" )
        {
            flag = false
        }
        if(passwordTextField.text! == "" ||  addressTextField.text! == "" ||  farmSizeTextField.text! == "" )
        {
            flag = false
        }
        return flag
        
    }
    
    
    
}


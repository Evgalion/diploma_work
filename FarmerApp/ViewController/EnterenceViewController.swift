//
//  ViewController.swift
//  FarmerApp
//
//  Created by Женя on 04.05.2023.
//

import UIKit
import GRDB
import SQLite



class EnterenceViewController: UIViewController {
    
    
    @IBOutlet weak var errorLabel: UILabel!
    private var dbQueue: DatabaseQueue?
    
    private var farmers: [Farmer] = []
    
    private var myLogger: LogManager!
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    //var db: OpaquePointer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        dbQueue = try? getDatabaseQueue()
        
    }
    
    
    private func getDatabaseQueue() throws -> DatabaseQueue {
        // on a real device you can't write data into a source DB file (you can only read it)
        // so we need to copy the source DB file intthe o "Application Support Directory"
        
        let fileManager = FileManager.default
        
        // getting a path to the the DB in "Application Support Directory"
        let dbPath = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("MyFarmerDB.sqlite").path
        
        // if the DB file doesn't exist at dbPath
        if !fileManager.fileExists(atPath: dbPath) {
            // getting a path to the source DB file
            let dbResourcePath = Bundle.main.path(forResource: "MyFarmerDB", ofType: "sqlite")!
            // copying the DB file into dbPath
            try fileManager.copyItem(atPath: dbResourcePath, toPath: dbPath)
        }
        
        return try DatabaseQueue(path: dbPath)
    }
    
    
    
    
    
    @IBAction func enterButtonPressed(_ sender: UIButton) {
        
        errorLabel.text = ""
        farmers = []
        if(phoneTextField.text != "" && passwordTextField.text != "")
        {
            let enteredPhoneNumber = phoneTextField.text!
            let enteredPassword = passwordTextField.text!
            print("\(enteredPhoneNumber) \(enteredPassword)")
            try? dbQueue?.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM Farmer where phone_number = ? and password = ?", arguments: [enteredPhoneNumber,enteredPassword])
                
                for row in rows {
                    farmers.append(Farmer(id: row[0], first_name: row[1], second_name: row[2], phone_number: row[3], password: row[4], main_address: row[5], farm_size: row[6]))
                }
                
            }
            
            
            if let value = farmers.first?.id
            {
                //створення Логера та запис в нього інформації
                myLogger = LogManager(String(farmers.first!.phone_number))
                myLogger.log("Пользователь \(farmers.first!.first_name) успешно вошёл")
                
                self.performSegue(withIdentifier: "goToData", sender: self)
            }
            else
            {
                print("error")
                errorLabel.text = "Ошибка такого аккаунта не существует"
            }
        }
        else
        {
            errorLabel.text = "Не все поля заполненные"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToData"
        {
            let MainVC:MainViewController = segue.destination as! MainViewController
            
            MainVC.farmerID = farmers[0].id
            MainVC.dbQueue = dbQueue
        }
        if segue.identifier == "gotoRegister"
        {
            let RegisterVC:RegisterViewController = segue.destination as! RegisterViewController
            RegisterVC.dbQueue = dbQueue
        }
    }
    
    
    @IBAction func registraitionButtonPressed(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "gotoRegister", sender: self)
        
    }
    
    
}


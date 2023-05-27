//
//  LoggerViewController.swift
//  FarmerApp
//
//  Created by Женя on 26.05.2023.
//

import Foundation
import UIKit


class LoggerViewController: UIViewController {
    
    @IBOutlet weak var logTextView: UITextView!
    
    public var log_data:String?
    
    public var filteredLogData: [String]?
    
    private var currentData: Date?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        logTextView.text = log_data
    }
    
    
    

    @IBAction func dataValueChanged(_ sender: UIDatePicker) {
                
        currentData = sender.date
        updateTextView()
    }
    
    
    private func updateTextView()
    {
        let stringsFromFunc = filterStrings()
        logTextView.text = ""
        
        for string in stringsFromFunc {
            logTextView.text += string + "\n"
        }
        
    }
    
    
    private func filterStrings() -> [String] {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" 
        
        
        let selectedDateString = dateFormatter.string(from: currentData!)
        
        var logStrings = log_data!.components(separatedBy: "\n")
        
        var newLogDate: [String] = [""]
        
        for string in logStrings {
            if string.contains(selectedDateString)
            {
                newLogDate.append(string)
            }
        }
        
        return newLogDate
    }
    
    
    
    @IBAction func returnAllLogData(_ sender: Any) {
        
        logTextView.text = log_data
    }
    
}

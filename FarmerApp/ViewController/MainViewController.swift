//
//  MainViewController.swift
//  FarmerApp
//
//  Created by Женя on 10.05.2023.
//

import Foundation
import UIKit
import GRDB


class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate {
   
    private var myLogger: LogManager?
    public var dbQueue: DatabaseQueue?
    
    
    private var tapGestureRecognizer: UITapGestureRecognizer!

    var MyFarmer: Farmer?
    var farmerID:Int = 0
    
    @IBOutlet weak var requestTableView: UITableView!
    
    
    @IBOutlet weak var myTabBar: UITabBar!
    
    private var requests: [Frequest] = []
    
    private var choosedRequest:Frequest?
    
    private var countFilter = 0
    
    private var TradersCount: Int = 1
    
    private var filters = ["Все","Подготовлен","Обрабатывается","Завершён"]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Установить индекс выбранной вкладки
        myTabBar.selectedItem = myTabBar.items?[0]
        
        
        loadData("Все")
        myLogger?.log("Загружаєм все предложения")
        requestTableView.delegate = self
        requestTableView.dataSource = self
        myTabBar.delegate = self
        
        // Создаем жест распознавания двойного нажатия
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
             tapGestureRecognizer.numberOfTapsRequired = 2
             
             // Добавляем жест распознавания к таблице
        requestTableView.addGestureRecognizer(tapGestureRecognizer)
        
        // Открываем лог файл.
        _ = getFarmer()
        myLogger = LogManager(MyFarmer!.phone_number)
        
        // Выполнение GET-запроса и получаем TradersCount
//               getTradersCount { [weak self] result in
//                   switch result {
//                   case .success(let count):
//                       self?.TradersCount = count
//                       self?.myLogger?.log("Traders count: \(count)")
//                   case .failure(let error):
//                       self?.myLogger?.log("Failed to get traders count: \(error)")
//                   }
//               }
        
    }
    
    @objc func handleDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            // Проверяем, что жест распознавания произошел в таблице
            if gestureRecognizer.view === requestTableView {
                // Получаем координаты точки касания в таблице
                let touchPoint = gestureRecognizer.location(in: requestTableView)
                
                // Получаем индекс ячейки, на которую было произведено двойное нажатие
                if let indexPath = requestTableView.indexPathForRow(at: touchPoint) {
                    // Обработка двойного нажатия на ячейку
                    myLogger?.log("Загружаєм пдф файл соответтвующего предложения \(requests[indexPath.row].id)")

                    if let fileURL = PDFCreator.generatePDFFileURL(for: requests[indexPath.row].id, requests[indexPath.row].date_created ) {
                        
                        //!!!!!!!!!!!!!!!!!!!!!!!!!! add
                        PDFCreator.openPDFFile(at: fileURL, from: self, requests[indexPath.row], getFarmer())
                    }
                }
            }
        }
    
    // MARK: Settings TableView
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RequestTableViewCell
        
        let request = requests[indexPath.row]
        
        cell.idLabel.text = request.getId()
        cell.informationLabel.text = request.getInformation()
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                // Удаление выбранной ячейки из источника данных
               
                if(deleteRequest(requests[indexPath.row]))
                   {
                    requests.remove(at: indexPath.row)
                    // Удаление ячейки из таблицы
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    }
            }
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        choosedRequest = requests[indexPath.row]
        }
    
    
    
    // MARK: Prepare Some Buttons

    
    @IBAction func loadDataButtonPressed(_ sender: Any) {
        loadData(filters[countFilter])
    }
    
   
    private func loadData(_ status:String)
    {
        requests = []
        if(status == filters[0])
        {
            try? dbQueue?.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM Frequest where farmer_id = \(farmerID)")
                
                for row in rows {
                    requests.append(Frequest(id: row[0], farmer_id: row[1], product: row[2], quality: row[3], weight: row[4],type_weight: row[5], price: row[6],type_price: row[7], date_created: row[8], status: row[9], Traderid : row[10]))
                }
            }
            myLogger?.log("Загружаєм все предложения")
        }
        else
        {
            try? dbQueue?.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM Frequest where farmer_id = ? and status = ?",arguments: [farmerID,status])
                
                for row in rows {
                    requests.append(Frequest(id: row[0], farmer_id: row[1], product: row[2], quality: row[3], weight: row[4],type_weight: row[5], price: row[6],type_price: row[7], date_created: row[8], status: row[9],Traderid: row[10]))
                }
            }
            myLogger?.log("Загружаєм все предложения со статусом \(status)")
        }
        requestTableView.reloadData()
        
    }
    
   
    @IBAction func addButtonPressed(_ sender: Any) {
        myLogger?.log("Переходим к созданию нового Предложения")
        self.performSegue(withIdentifier: "goToAddRequest", sender: self)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddRequest"
        {
            let ReqCreateVC:RequestCreateViewController = segue.destination as! RequestCreateViewController
            
            ReqCreateVC.farmerID = farmerID
            ReqCreateVC.dbQueue = dbQueue
            ReqCreateVC.TraderIDCount = TradersCount
        }
        else if segue.identifier == "goToMyLog"
        {
            let LogVC :LoggerViewController = segue.destination as! LoggerViewController
            LogVC.log_data = myLogger?.getLogHistory()
            
        }
    }
    
   
    
    @IBAction func sendButtonPressed(_ sender: Any)
    {
        sendDataToServer(selectedRequest: choosedRequest!)
    }
    
    //Отправка запроса на сервис
    func sendDataToServer(selectedRequest: Frequest) {
        if(selectedRequest.status == filters[1])
        {
            guard let url = URL(string: "https://localhost:44345/api/UniversalAPIController/SendAPIJson") else {
                return
            }
            
            if(UIApplication.shared.canOpenURL(url))
            {
                myLogger?.log("Инициализируем наш api url = \(url)")
                
                var request = URLRequest(url: url)
                request.httpMethod = "PUT"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                myLogger?.log("Cоздали запрос типа \(request.httpMethod)")
                
                let jsonData = try? JSONEncoder().encode(["selectedRequest": selectedRequest])
                
                
                request.httpBody = jsonData
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                        print("Error: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    self.updateRequestStatus(selectedRequest,status: self.filters[2])
                    
                    if response.statusCode == 200 {
                        print("Data successfully sent to server")
                        self.updateRequestStatus(selectedRequest,status: self.filters[3])
                    } else {
                        print("Server error: \(response.statusCode)")
                    }
                    self.myLogger?.log("Спробывали отправить json. Ответ сервера = \(response.statusCode)")
                }
                
                task.resume()
            }
        }
    }
    
    
    func updateRequestStatus(_ selectedRequest: Frequest, status: String)
    {
        
        let sqlText = "UPDATE FRequest SET status = ? WHERE id = ?"
        
        do{
            try dbQueue?.write { db in
                try db.execute(sql: sqlText, arguments: [status, selectedRequest.id])
            }
        }
            catch {
                   print("Произошла неизвестная ошибка: \(error)")
               }
    }
    
    func deleteRequest(_ selectedRequest: Frequest) -> Bool
    {
        let sqlText = "DELETE FROM FRequest WHERE id = ? and status = ?"
        
        do{
            try dbQueue?.write { db in
                try db.execute(sql: sqlText, arguments: [ selectedRequest.id, "Подготовлен"])
            }
            
        }
            catch {
                   print("Произошла неизвестная ошибка: \(error)")
                return false
               }
        return true
    }
    
    func getFarmer() -> String
    {
        var data_farmer:String
        var farmers: [Farmer] = []
        try? dbQueue?.read { db in
            let rows = try Row.fetchAll(db, sql: "SELECT * FROM Farmer where id = ?",arguments: [farmerID])
            
            for row in rows {
                farmers.append(Farmer(id: row[0], first_name: row[1], second_name: row[2], phone_number: row[3], password: row[4], main_address: row[5], farm_size: row[6]))
            }
        }
        
       
        data_farmer = "\(farmers[0].first_name) \(farmers[0].second_name). Живущий за адрессом \(farmers[0].main_address)"
        self.MyFarmer = farmers[0]
        return data_farmer
    }
    


    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // Обработка выбора вкладки
        countFilter = item.tag
        
        loadData(filters[countFilter])
         // Инкремент индекса фильтра с учетом границы массива
        let currentFilter = filters[countFilter]
    
     
     myLogger?.log("Меняем сортировку предложений на \(currentFilter)")
     
     if let unwrappedString = myLogger?.getLogHistory() {
         print(unwrappedString)
     } else {
         print("Строка має значення nil.")
     }
        
    }
    
    
    
    @IBAction func logButtonPressed(_ sender: UIButton) {
        
   
        // Обработка двойного нажатия на ячейку
        myLogger?.log("Загружаєм пдф файл для истории логера")
        
        if let tmpString = myLogger?.getLogFileName()
        {
            
            self.performSegue(withIdentifier: "goToMyLog", sender: self)
        
        }
    }
    
    
    
    func getTradersCount(completion: @escaping (Result<Int, Error>) -> Void) {
            let urlString = "https://localhost:44345/api/UniversalAPIController/GetTradesID" // Замените на URL вашего сервера
            
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    let count = json?["LastId"] as? Int ?? 0
                    completion(.success(count))
                } catch {
                    completion(.failure(error))
                }
            }
            
            task.resume()
        }
    
    
}
    

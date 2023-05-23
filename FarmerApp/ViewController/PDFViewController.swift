//
//  PDFViewController.swift
//  FarmerApp
//
//  Created by Женя on 17.05.2023.
//

import Foundation
import UIKit
import PDFKit

class PDFViewController: UIViewController {
    private var pdfURL: URL
    private var additionalData: Frequest // Замените YourDataType на тип данных, который вы хотите передать
    private var creator_name: String

    private lazy var pdfView: PDFView = {
       let view = PDFView(frame: UIScreen.main.bounds)
       view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
       view.displayMode = .singlePageContinuous
       view.autoScales = true
       return view
    }()

    init(url: URL, additionalData: Frequest,creator_name:String) {
        self.pdfURL = url
        self.additionalData = additionalData
        self.creator_name = creator_name
        super.init(nibName: nil, bundle: nil)
       modalPresentationStyle = .overCurrentContext // Измените стиль модального представления
    }
     
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
                view.addSubview(pdfView)
                
                // Add a button to close the document
                let closeButton = UIButton(type: .system)
                closeButton.setTitle("Close", for: .normal)
                closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
                view.addSubview(closeButton)
                
                // Position and layout the button
                closeButton.translatesAutoresizingMaskIntoConstraints = false
                closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
                closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
                
                openOrCreatePDFFile()
    
    }
    
    
    private func openOrCreatePDFFile() {
            // Проверка, существует ли файл по указанному пути
            if FileManager.default.fileExists(atPath: pdfURL.path) {
                // Если файл существует, открыть его
                // Если файл существует, удалить его
                        do {
                            try FileManager.default.removeItem(at: pdfURL)
                        } catch {
                            print("Ошибка при удалении существующего PDF-файла: \(error.localizedDescription)")
                        }
                createAndDisplayPDF()
                
//                if let document = PDFDocument(url: pdfURL) {
//
//
//                    pdfView.document = document
//                } else {
//                    print("Ошибка при открытии PDF-файла.")
//                }
            } else {
                // Если файл не существует, создать и открыть новый файл
                createAndDisplayPDF()
            }
        }
        
        private func createAndDisplayPDF() {
            
            
            let body: String = " Номер заявки: \(additionalData.id)\n Создана: \(creator_name)\n По продаже товара: \(additionalData.product)\n Качества: \(additionalData.quality)\n Вес всей продукции: \(additionalData.weight) \(additionalData.type_weight)\n По цене \(additionalData.price)\(additionalData.type_price) за 1 \(additionalData.type_weight)\n Дата создания заявки: \(additionalData.date_created)\n Статус заявки: \(additionalData.status)\n Общая сума: \(Double(additionalData.price) * Double(additionalData.weight)) \(additionalData.type_price)"
            
            let pdfCreator = PDFCreator(title: "Информация об заявке на продажу", body: body)
            // Создание документа PDF
//            let pdfDocument = PDFDocument()
//
//            // Создание страницы PDF
//            let page = PDFPage()
//
//            // Создание текстового блока на странице
//            let annotation = PDFAnnotation(bounds: CGRect(x: 0, y: 0, width: 100, height: 20), forType: .freeText, withProperties: nil)
//            annotation.contents = "Hello, world!"
//            annotation.font = UIFont.systemFont(ofSize: 15.0)
//            annotation.fontColor = .black
//            annotation.color = .clear
//
//            // Получение размеров страницы
//            guard let page = pdfDocument.page(at: 0) else {
//                return
//            }
//            let pageBounds = page.bounds(for: .mediaBox)
//
//            // Расчет координат для размещения текстового блока по центру
//            let annotationWidth: CGFloat = 100.0
//            let annotationHeight: CGFloat = 20.0
//            let annotationX = (pageBounds.width - annotationWidth) / 2
//            let annotationY = (pageBounds.height - annotationHeight) / 2
//
//            // Установка новых координат для текстового блока
//            annotation.bounds = CGRect(x: annotationX, y: annotationY, width: annotationWidth, height: annotationHeight)
//
//            // Добавление текстового блока на страницу
//            page.addAnnotation(annotation)
//
//            // Добавление страницы в документ
//            pdfDocument.insert(page, at: pdfDocument.pageCount)
//
//            // Сохранение документа по указанному пути
//            pdfDocument.write(to: pdfURL)
            
            // Отображение PDF на UIView
            // pdfView.document = pdfDocument
            
            pdfView.document = PDFDocument(data: pdfCreator.createFlyer())
        }
    
  
    
    
    
    
    @objc private func closeButtonTapped() {
           dismiss(animated: true, completion: nil)
       }
}

//
//  PDFCreator.swift
//  FarmerApp
//
//  Created by Женя on 17.05.2023.
//

import Foundation
import UIKit
import PDFKit

struct PDFCreator {

    let title: String
    let body: String

    static func generatePDFFileURL(for row: Int, _ date: String) -> URL? {

        let fileName = "document_\(row)_\(date)" // Генерируем имя файла на основе индекса ячейки

           // Получаем путь к директории документов в приложении
           guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
               return nil
           }
           // Создаем полный URL-адрес файла с использованием директории документов и имени файла
           let fileURL = documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("pdf")

           return fileURL
       }
    static func generatePDFFileURL( _ logname: String) -> URL? {

        let fileName = "document_log_history_\(logname)" // Генерируем имя файла на основе индекса ячейки

           // Получаем путь к директории документов в приложении
           guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
               return nil
           }
           // Создаем полный URL-адрес файла с использованием директории документов и имени файла
           let fileURL = documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("pdf")

           return fileURL
       }

    static func openPDFFile(at fileURL: URL, from viewController: UIViewController, _ data:Frequest, _ data_f:String) {
        let documentViewController = PDFViewController(url: fileURL,additionalData: data,creator_name: data_f )
        let navigationController = UINavigationController(rootViewController: documentViewController)
        navigationController.modalPresentationStyle = .currentContext
        viewController.present(navigationController, animated: true, completion: nil)
    }

    // Редачим
//    static func openPDFLoggerHistory(at fileURL: URL, from viewController: UIViewController, _ log_data:String ) {
//        let documentViewController =  PDFLoggerViewController(url: fileURL, additionalData: log_data)
//        let navigationController = UINavigationController(rootViewController: documentViewController)
//        navigationController.modalPresentationStyle = .currentContext
//        viewController.present(navigationController, animated: true, completion: nil)
//    }



    func createFlyer() -> Data {
      // 1
      let pdfMetaData = [
        kCGPDFContextTitle: title
      ]
      let format = UIGraphicsPDFRendererFormat()
      format.documentInfo = pdfMetaData as [String: Any]

      // 2
      let pageWidth = 8.5 * 72.0
      let pageHeight = 14 * 72.0
      let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

      // 3
      let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
      // 4
      let data = renderer.pdfData { (context) in
        // 5
        context.beginPage()
        // 6
        let titleBottom = addTitle(pageRect: pageRect)
        addBodyText(pageRect: pageRect, textTop: titleBottom + 18.0 + 18.0)
      }

      return data
    }

    func addTitle(pageRect: CGRect) -> CGFloat {
      // 1
      let titleFont = UIFont.systemFont(ofSize: 18.0, weight: .bold)
      // 2
      let titleAttributes: [NSAttributedString.Key: Any] =
        [NSAttributedString.Key.font: titleFont]
      let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
      // 3
      let titleStringSize = attributedTitle.size()
      // 4
      let titleStringRect = CGRect(x: (pageRect.width - titleStringSize.width) / 2.0,
                                   y: 36, width: titleStringSize.width,
                                   height: titleStringSize.height)
      // 5
      attributedTitle.draw(in: titleStringRect)
      // 6
      return titleStringRect.origin.y + titleStringRect.size.height
    }

    func addBodyText(pageRect: CGRect, textTop: CGFloat) {
      // 1
      let textFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
      // 2
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.alignment = .natural
      paragraphStyle.lineBreakMode = .byWordWrapping
      // 3
      let textAttributes = [
        NSAttributedString.Key.paragraphStyle: paragraphStyle,
        NSAttributedString.Key.font: textFont
      ]
      let attributedText = NSAttributedString(string: body, attributes: textAttributes)
      // 4
      let textRect = CGRect(x: 10, y: textTop, width: pageRect.width - 20,
                            height: pageRect.height - textTop - pageRect.height / 5.0)
      attributedText.draw(in: textRect)
    }
    
    
//    func addBodyText(pageRect: CGRect, textTop: CGFloat) {
//        let maxFontSize: CGFloat = 12.0
//        var fontSize: CGFloat = maxFontSize
//
//        // 1
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.alignment = .natural
//        paragraphStyle.lineBreakMode = .byWordWrapping
//
//        // 2
//        var textAttributes: [NSAttributedString.Key: Any] = [
//            NSAttributedString.Key.paragraphStyle: paragraphStyle,
//            NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)
//        ]
//
//        // 3
//        var attributedText = NSAttributedString(string: body, attributes: textAttributes)
//
//        // 4
//        var textRect = CGRect(x: 10, y: textTop, width: pageRect.width - 20, height: pageRect.height - textTop - pageRect.height / 5.0)
//
//        while attributedText.size().height > textRect.height && fontSize > 0 {
//            // Уменьшаем размер шрифта и обновляем атрибуты текста
//            fontSize -= 1.0
//            textAttributes[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: fontSize, weight: .regular)
//            attributedText = NSAttributedString(string: body, attributes: textAttributes)
//        }
//
//        // Перерассчитываем прямоугольник для масштабированного текста
//        textRect = CGRect(x: 10, y: textTop, width: pageRect.width - 20, height: attributedText.size().height)
//
//        // Отрисовываем масштабированный текст
//        attributedText.draw(in: textRect)
//    }



    func getAttributedText() -> NSAttributedString
    {
        // 1
        let textFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        // 2
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping
        // 3
        let textAttributes = [
          NSAttributedString.Key.paragraphStyle: paragraphStyle,
          NSAttributedString.Key.font: textFont
        ]
        let attributedText = NSAttributedString(string: body, attributes: textAttributes)

        return attributedText
    }

}


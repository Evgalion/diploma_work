//
//  LogManager.swift
//  FarmerApp
//
//  Created by Женя on 21.05.2023.
//

import os.log
import Foundation

class LogManager {
    private let logFileName = "app_log.txt"
    private let logFileURL: URL
    
    init(_ str: String) {
        // Определите путь к файлу
        let logFileName = str + "_" + logFileName
        
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            logFileURL = documentsDirectory.appendingPathComponent(logFileName)
        } else {
            fatalError("Не удалось получить путь к директории документов")
        }
        
        // Создайте файл логов, если его нет
        createLogFileIfNeeded()
    }
    
    private func createLogFileIfNeeded() {
        if !FileManager.default.fileExists(atPath: logFileURL.path) {
            FileManager.default.createFile(atPath: logFileURL.path, contents: nil, attributes: nil)
        }
    }
    
    func log(_ message: String) {
        // Запишите сообщение в журнал
        os_log("%@", log: OSLog.default, type: .info, message)
        
        // Сохраните сообщение в файле логов
        appendLogToFile(message)
    }
    
    private func appendLogToFile(_ message: String) {
        if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
            fileHandle.seekToEndOfFile()
            let logData = "\(getCurrentTimestamp()): \(message)\n".data(using: .utf8)
            fileHandle.write(logData!)
            fileHandle.closeFile()
        } else {
            fatalError("Не удалось открыть файл логов для записи")
        }
    }
    
    private func getCurrentTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
    
    func getLogHistory() -> String {
        do {
            // Прочитайте содержимое файла логов
            let logContent = try String(contentsOf: logFileURL, encoding: .utf8)
            return logContent
        } catch {
            return "Ошибка при чтении файла логов"
        }
    }
}

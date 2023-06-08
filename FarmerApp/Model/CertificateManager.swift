//
//  CertificateManager.swift
//  FarmerApp
//
//  Created by Женя on 08.06.2023.
//

import Foundation
import Security

class CertificateManager {
    let certificateAuthorityURL = URL(string: "https://your-certificate-authority.com")!

    func generateAndSendPrivateKey() {
        // Генерация секретного ключа
        guard let privateKey = generatePrivateKey() else {
            print("Failed to generate private key.")
            return
        }

        // Отправка секретного ключа на центр сертификации
        sendPrivateKeyToCertificateAuthority(privateKey)
    }

    func generatePrivateKey() -> SecKey? {
        let privateKeyParams: [String: Any] = [
            kSecAttrIsPermanent as String: false
        ]

        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(privateKeyParams as CFDictionary, &error) else {
            print("Failed to generate private key: \(error.debugDescription)")
            return nil
        }

        return privateKey
    }

    func sendPrivateKeyToCertificateAuthority(_ privateKey: SecKey) {
        // Конвертация секретного ключа в PEM-формат
        guard let privateKeyPEM = convertPrivateKeyToPEM(privateKey) else {
            print("Failed to convert private key to PEM format.")
            return
        }

        // Отправка секретного ключа на центр сертификации (ваш код для отправки данных privateKeyPEM на сервер)
        // Например, используйте URLSession для выполнения запроса POST

        let requestURL = certificateAuthorityURL.appendingPathComponent("registerPrivateKey")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.httpBody = privateKeyPEM.data(using: .utf8)

        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Failed to send private key: \(error.localizedDescription)")
                return
            }

            // Обработка ответа от центра сертификации
            guard let responseData = data, let publicKeyPEM = String(data: responseData, encoding: .utf8) else {
                print("Invalid response from certificate authority.")
                return
            }

            // Получение открытого ключа для шифрования
            guard let publicKey = self.convertPEMToPublicKey(publicKeyPEM) else {
                print("Failed to convert public key from PEM format.")
                return
            }

            // Используйте publicKey для шифрования данных
            self.encryptDataWithPublicKey(publicKey)
        }

        task.resume()
    }

    func convertPrivateKeyToPEM(_ privateKey: SecKey) -> String? {
        var error: Unmanaged<CFError>?
        guard let privateKeyData = SecKeyCopyExternalRepresentation(privateKey, &error) as Data? else {
            print("Failed to get private key data: \(error.debugDescription)")
            return nil
        }

        let base64PrivateKey = privateKeyData.base64EncodedString()
        let pemKey = """
        -----BEGIN PRIVATE KEY-----
        \(base64PrivateKey)
        -----END PRIVATE KEY-----
        """

        return pemKey
    }

    func convertPEMToPublicKey(_ publicKeyPEM: String) -> SecKey? {
        // Извлечение данных открытого ключа из PEM-формата
        let pemComponents = publicKeyPEM.components(separatedBy: "\n")
        let base64PublicKey = pemComponents.filter { $0.hasPrefix("-----BEGIN PUBLIC KEY-----") || $0.hasPrefix("-----END PUBLIC KEY-----") == false }.joined()

        guard let publicKeyData = Data(base64Encoded: base64PublicKey) else {
            print("Invalid public key data.")
            return nil
        }

        // Создание словаря с атрибутами открытого ключа
        let keyAttributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: 2048
        ]

        // Создание открытого ключа из данных
        var error: Unmanaged<CFError>?
        guard let publicKey = SecKeyCreateWithData(publicKeyData as CFData, keyAttributes as CFDictionary, &error) else {
            print("Failed to create public key: \(error.debugDescription)")
            return nil
        }

        return publicKey
    }

    func encryptDataWithPublicKey(_ publicKey: SecKey) {
        // Ваш код для шифрования данных с использованием открытого ключа
    }
}

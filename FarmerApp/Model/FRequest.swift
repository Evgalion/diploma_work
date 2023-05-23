//
//  FRequest.swift
//  FarmerApp
//
//  Created by Женя on 08.05.2023.
//

import Foundation

struct Frequest:Codable
{
    let id: Int
    let farmer_id: Int
    let product: String
    let quality: Int
    let weight: Double
    let type_weight: String
    let price: Int
    let type_price: String
    let date_created: String
    let status: String
    

    func getInformation() -> String
    {
        return "farmer_id: \(farmer_id), product: \(product), quality: \(quality),\n weight: \(weight), type_weight: \(type_weight),\n price: \(price), type_price: \(type_price),\n date_created: \(date_created), status: \(status)"
    }
    
    func getId() -> String {
        return String(id)
    }
}

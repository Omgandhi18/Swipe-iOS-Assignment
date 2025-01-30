//
//  Product.swift
//  Swipe iOS Assignment
//
//  Created by Om Gandhi on 29/01/2025.
//

import Foundation

//MARK: Product Model
struct Product: Codable, Identifiable{
    let id = UUID()
    let image: String
    let price: Double
    let product_name: String
    let product_type: String
    let tax: Double
    var isFavorite: Bool = false
    
    enum CodingKeys: String, CodingKey {
            case product_name = "product_name"
            case product_type = "product_type"
            case tax
            case price
            case image
        }
}

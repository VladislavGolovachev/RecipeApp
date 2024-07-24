//
//  MealInfo.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 25.07.2024.
//

import Foundation

struct MealInfoResponse: Decodable {
    var meals: [MealInfo]
}

struct MealInfo: Decodable {
    var id: String
    var name: String
    var photoString: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "idMeal"
        case name = "strMeal"
        case photoString = "strMealThumb"
    }
}

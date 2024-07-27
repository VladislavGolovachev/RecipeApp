//
//  MealInfo.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 25.07.2024.
//

import Foundation

struct MealInfo: Decodable {
    var id: String
    var name: String
    var photoString: String
    var photoData: Data?
    
    private enum CodingKeys: String, CodingKey {
        case id = "idMeal"
        case name = "strMeal"
        case photoString = "strMealThumb"
    }
}

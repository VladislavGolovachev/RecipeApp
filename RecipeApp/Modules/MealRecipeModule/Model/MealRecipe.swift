//
//  MealRecipe.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 25.07.2024.
//

import Foundation

struct MealRecipe: Decodable {
    var name: String
    var category: String
    var area: String
    var instruction: String
    var sourceLink: String
    lazy var ingredients: [Ingredient] = {
        var array = [
            Ingredient(ingredient: ingredient1, measure: measure1),
            Ingredient(ingredient: ingredient2, measure: measure2),
            Ingredient(ingredient: ingredient3, measure: measure3),
            Ingredient(ingredient: ingredient4, measure: measure4),
            Ingredient(ingredient: ingredient5, measure: measure5),
            Ingredient(ingredient: ingredient6, measure: measure6),
            Ingredient(ingredient: ingredient7, measure: measure7),
            Ingredient(ingredient: ingredient8, measure: measure8),
            Ingredient(ingredient: ingredient9, measure: measure9),
            Ingredient(ingredient: ingredient10, measure: measure10),
            Ingredient(ingredient: ingredient11, measure: measure11),
            Ingredient(ingredient: ingredient12, measure: measure12),
            Ingredient(ingredient: ingredient13, measure: measure13),
            Ingredient(ingredient: ingredient14, measure: measure14),
            Ingredient(ingredient: ingredient15, measure: measure15),
            Ingredient(ingredient: ingredient16, measure: measure16),
            Ingredient(ingredient: ingredient17, measure: measure17),
            Ingredient(ingredient: ingredient18, measure: measure18),
            Ingredient(ingredient: ingredient19, measure: measure19),
            Ingredient(ingredient: ingredient20, measure: measure20)
               ]
        //FIXME: Remove extra ingredients
//        var index = array.firstIndex { item in
//            return item.ingredient == "" && item.measure == ""
//        }
//        if let index {
//            array.removeSubrange(index...array.count)
//        }
        return array
    }()
    
    private var ingredient1, ingredient2, ingredient3, ingredient4, ingredient5,
                ingredient6, ingredient7, ingredient8, ingredient9, ingredient10,
                ingredient11, ingredient12, ingredient13, ingredient14, ingredient15,
                ingredient16, ingredient17, ingredient18, ingredient19, ingredient20: String
    
    private var measure1, measure2, measure3, measure4, measure5,
                measure6, measure7, measure8, measure9, measure10,
                measure11, measure12, measure13, measure14, measure15,
                measure16, measure17, measure18, measure19, measure20: String
        
    private enum CodingKeys: String, CodingKey {
        case name = "strMeal"
        case category = "strCategory"
        case area = "strArea"
        case sourceLink = "strSource"
        case instruction = "strInstructions"
        case ingredient1 = "strIngredient1",    ingredient2 = "strIngredient2",
             ingredient3 = "strIngredient3",    ingredient4 = "strIngredient4",
             ingredient5 = "strIngredient5",    ingredient6 = "strIngredient6",
             ingredient7 = "strIngredient7",    ingredient8 = "strIngredient8",
             ingredient9 = "strIngredient9",    ingredient10 = "strIngredient10",
             ingredient11 = "strIngredient11",  ingredient12 = "strIngredient12",
             ingredient13 = "strIngredient13",  ingredient14 = "strIngredient14",
             ingredient15 = "strIngredient15",  ingredient16 = "strIngredient16",
             ingredient17 = "strIngredient17",  ingredient18 = "strIngredient18",
             ingredient19 = "strIngredient19",  ingredient20 = "strIngredient20"
        case measure1 = "strMeasure1",      measure2 = "strMeasure2",
             measure3 = "strMeasure3",      measure4 = "strMeasure4",
             measure5 = "strMeasure5",      measure6 = "strMeasure6",
             measure7 = "strMeasure7",      measure8 = "strMeasure8",
             measure9 = "strMeasure9",      measure10 = "strMeasure10",
             measure11 = "strMeasure11",    measure12 = "strMeasure12",
             measure13 = "strMeasure13",    measure14 = "strMeasure14",
             measure15 = "strMeasure15",    measure16 = "strMeasure16",
             measure17 = "strMeasure17",    measure18 = "strMeasure18",
             measure19 = "strMeasure19",    measure20 = "strMeasure20"
    }
}

struct Ingredient {
    var ingredient: String
    var measure: String
}

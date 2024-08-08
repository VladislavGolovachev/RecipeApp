//
//  MealRecipePresenter.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 09.08.2024.
//

import Foundation

protocol MealRecipeViewPresenterProtocol: AnyObject {
    init(router: RouterProtocol, mealRecipe: MealRecipe)
    func loadLink()
    func getMealRecipe() -> MealRecipe
}

final class MealRecipePresenter: MealRecipeViewPresenterProtocol {
    var router: RouterProtocol
    private let mealRecipe: MealRecipe
    
    init(router: RouterProtocol, mealRecipe: MealRecipe) {
        self.mealRecipe = mealRecipe
        self.router = router
    }
    
    func loadLink() {
        self.router.showSourceController()
    }
    
    func getMealRecipe() -> MealRecipe {
        return mealRecipe
    }
}

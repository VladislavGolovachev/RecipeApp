//
//  MealRecipePresenter.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 09.08.2024.
//

import Foundation

protocol MealRecipeViewProtocol: AnyObject {
    func showSourceLink()
}

protocol MealRecipeViewPresenterProtocol: AnyObject {
    init(view: MealRecipeViewProtocol, router: RouterProtocol, mealRecipe: MealRecipe)
    func loadLink()
    func getMealAttribute(_ attribute: MealAttribute) -> String
    func getSourceLink() -> String?
    func getMealIngredientsString() -> String
    func checkSourceLinkExistence()
}

final class MealRecipePresenter: MealRecipeViewPresenterProtocol {
    
    weak var view: MealRecipeViewProtocol?
    var router: RouterProtocol
    private var mealRecipe: MealRecipe
    
    init(view: MealRecipeViewProtocol, router: RouterProtocol, mealRecipe: MealRecipe) {
        self.view = view
        self.mealRecipe = mealRecipe
        self.router = router
    }
    
    func loadLink() {
        if let link = mealRecipe.sourceLink {
            self.router.showWebSourceController(link: link)
        }
        
    }
    
    func getMealAttribute(_ attribute: MealAttribute) -> String {
        switch attribute {
        case .name:
            return mealRecipe.name
        case .category:
            return mealRecipe.category
        case .area:
            return mealRecipe.area
        case .instruction:
            return mealRecipe.instruction
        }
    }
    
    func getSourceLink() -> String? {
        return mealRecipe.sourceLink
    }
    
    func getMealIngredientsString() -> String {
        var text = ""
        for item in mealRecipe.ingredients {
            guard let ingredient = item.ingredient, let measure = item.measure else {
                return text
            }
            if ingredient == "" {
                return text
            }
            text += ingredient + " " + measure + "\n"
        }
        return text
    }
    
    func checkSourceLinkExistence() {
        if let link = mealRecipe.sourceLink, link != "" {
            self.view?.showSourceLink()
        }
    }
}

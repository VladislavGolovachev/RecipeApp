//
//  ModuleBuilder.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 25.07.2024.
//

import UIKit

protocol ModuleBuilderProtocol {
    func createMealListModule(router: RouterProtocol) -> UIViewController
    func createMealRecipeModule(router: Router, mealRecipe: MealRecipe) -> UIViewController
}

class ModuleBuilder: ModuleBuilderProtocol {
    func createMealListModule(router: RouterProtocol) -> UIViewController {
        let vc = MealListViewController()
        let presenter = MealListPresenter(view: vc, router: router)
        vc.presenter = presenter
        
        return vc
    }
    
    func createMealRecipeModule(router: Router, mealRecipe: MealRecipe) -> UIViewController {
        let vc = MealRecipeViewController()
        let presenter = MealRecipePresenter(view: vc, router: router, mealRecipe: mealRecipe)
        vc.presenter = presenter
        
        return vc
    }
}

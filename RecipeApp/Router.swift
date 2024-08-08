//
//  Router.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 08.08.2024.
//

import UIKit

protocol RouterProtocol {
    init(navigationController: UINavigationController, moduleBuilder: ModuleBuilderProtocol)
    func initiateRootController()
    func showMealRecipeController(mealRecipe: MealRecipe)
    func showSourceController()
}

final class Router: RouterProtocol {
    let navigationController: UINavigationController
    let moduleBuilder: ModuleBuilderProtocol
    
    init(navigationController: UINavigationController, moduleBuilder: ModuleBuilderProtocol) {
        self.navigationController = navigationController
        self.moduleBuilder = moduleBuilder
    }
    
    func initiateRootController() {
        let mealListVC = moduleBuilder.createMealListModule(router: self)
        self.navigationController.viewControllers = [mealListVC]
    }
    
    func showMealRecipeController(mealRecipe: MealRecipe) {
        let mealRecipeVC = moduleBuilder.createMealRecipeModule(router: self, mealRecipe: mealRecipe)
        self.navigationController.pushViewController(mealRecipeVC, animated: true)
    }
    
    func showSourceController() {
        let sourceVC = SourceViewController()
        self.navigationController.pushViewController(sourceVC, animated: true)
    }
}

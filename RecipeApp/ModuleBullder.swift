//
//  ModuleBuilder.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 25.07.2024.
//

import UIKit

protocol ModuleBuilderProtocol {
    func createListModule() -> UIViewController
    func createRecipeModule() -> UIViewController
}

class ModuleBuilder: ModuleBuilderProtocol {
    func createListModule() -> UIViewController {
        let vc = MealListViewController()
        let presenter = MealListPresenter(view: vc)
        vc.presenter = presenter
        
        return vc
    }
    
    func createRecipeModule() -> UIViewController {
        let vc = UIViewController()
        
        return vc
    }
}

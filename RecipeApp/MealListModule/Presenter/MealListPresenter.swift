//
//  MealListPresenter.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 25.07.2024.
//

import Foundation

protocol MealListViewProtocol: AnyObject{
    func showList(of meals: [Meal])
    func loadData()
}

protocol MealListViewPresenterProtocol: AnyObject {
    init(view: MealListViewController)
    func getMeals()
    func didSelectMeal(with id: Int)
}

class MealListPresenter: MealListViewPresenterProtocol {
    
    weak var view: MealListViewProtocol?
    
    required init(view: MealListViewController) {
        self.view = view
    }
    
    func getMeals() {
        var meals = [Meal]()
        let group = DispatchGroup()
        
        for _ in 1...16 {
            
            group.enter()
            NetworkService.shared.getRandomMeal { [weak self] result in
                switch result {
                case .success(let mealsResponse):
                    if let meal = mealsResponse.meals.first {
                        meals.append(meal)
                        DispatchQueue.main.async {
                            self?.view?.showList(of: meals)
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if meals.count == 0 {
                self.view?.loadData()
            }
        }
    }

    func didSelectMeal(with id: Int) {
        print("Go to the next screen")
    }
}

//
//  MealListPresenter.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 25.07.2024.
//

import Foundation

protocol MealListViewProtocol: AnyObject{
    func showList()
}

protocol MealListViewPresenterProtocol: AnyObject {
    init(view: MealListViewController)
    func downloadMeals()
    func getMeals() -> [MealInfo]
    func didSelectMeal(with id: Int)
}

class MealListPresenter: MealListViewPresenterProtocol {
    
    weak var view: MealListViewProtocol?
    
    required init(view: MealListViewController) {
        self.view = view
    }
    
    func downloadMeals() {
        var meals = [MealInfo]()
        let group = DispatchGroup()
        
        for _ in 1...24 {
            
            group.enter()
            NetworkService.shared.getRandomMeal { result in
                switch result {
                case .success(let mealsResponse):
                    if let meal = mealsResponse.meals.first {
                        meals.append(meal)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {

            if meals.isEmpty {
            } else {
                DataManager.shared.save(meals)
                DispatchQueue.main.async {
                    self.view?.showList()
                }
                
                self.downloadPictures(for: meals) { result in
                    switch result {
                    case .success(let mealsWithPics):
                        DispatchQueue.global().async {
                            DataManager.shared.clear()
                            DataManager.shared.persist(meals)
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    //FIXME: Fix to have access to local files
    func getMeals() -> [MealInfo] {
        return DataManager.shared.meals ?? [MealInfo]()
    }

    func didSelectMeal(with id: Int) {
        print("Go to the next screen")
    }
}

extension MealListPresenter {
    
    private func downloadPictures(for meals: [MealInfo], completion: @escaping (Result<[MealInfo], Error>) -> Void) {
        var mealsCopy = meals
        
        for (index, meal) in meals.enumerated() {
            let downloadPictureWorkItem = DispatchWorkItem {
                NetworkService.shared.downloadPhotoData(by: meal.photoString) { result in
                    switch result {
                    case .success(let data):
                        mealsCopy[index].photoData = data
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
            
            DispatchQueue.global(qos: .userInitiated).async(execute: downloadPictureWorkItem)
            downloadPictureWorkItem.notify(queue: .main) {
                DataManager.shared.save(mealsCopy)
                self.view?.showList()
            }
        }
    }
}

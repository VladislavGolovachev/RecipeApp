//
//  MealListPresenter.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 25.07.2024.
//

import UIKit

protocol MealListViewProtocol: AnyObject {
    func showList()
    func updateList(at row: Int)
    func showAlert(message: String)
}

protocol MealListViewPresenterProtocol: AnyObject {
    init(view: MealListViewProtocol, router: RouterProtocol)
    func downloadMeals(isDataToBeOverwritten: Bool, isAlertShouldBeShown: Bool, completion: @escaping () -> Void)
    func getMeal(of number: Int) -> Meal?
    func getMealCount() -> Int
    func goToRecipeScreen(with number: Int)
}

class MealListPresenter: MealListViewPresenterProtocol {
    
    weak var view: MealListViewProtocol?
    var router: RouterProtocol?
    
    required init(view: MealListViewProtocol, router: RouterProtocol) {
        self.view = view
        self.router = router
    }
    
    func downloadMeals(isDataToBeOverwritten: Bool, isAlertShouldBeShown: Bool, completion: @escaping () -> Void) {
        var meals = [MealInfo]()
        let group = DispatchGroup()
        
        for _ in 1...18 {
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
        
        group.notify(queue: .global(qos: .utility)) {
            let isRequestSuccessful = !meals.isEmpty

            if isRequestSuccessful {
                self.saveToLocal(meals, with: isDataToBeOverwritten)
            }
            DispatchQueue.main.async {
                completion()
                self.view?.showList()
            }
            if isAlertShouldBeShown && !isRequestSuccessful {
                DispatchQueue.main.async {
                    self.view?.showAlert(message: "Unable to load new recipes")
                }
            }
            if isRequestSuccessful {
                self.downloadPictures(for: meals)
            }
        }
    }
    
    func getMeal(of number: Int) -> Meal? {
        let meal = DataManager.shared.fetchMeal(of: number)
        return meal
    }
    
    func getMealCount() -> Int {
        let count = DataManager.shared.mealsCount()
        return count
    }

    func goToRecipeScreen(with number: Int) {
        guard let meal = DataManager.shared.fetchMeal(of: number) else {return}
        let id = meal.id
        NetworkService.shared.getMealRecipe(of: id) { result in
            
            print("RecipeScreen")
            switch result {
            case .success(let mealRecipeResponse):
                guard let mealRecipe = mealRecipeResponse.recipes.first else {return}
                DispatchQueue.main.async {
                    self.router?.showMealRecipeController(mealRecipe: mealRecipe)
                }
                
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.view?.showAlert(message: "Unable to show recipe")
                }
            }
        }
    }
}

extension MealListPresenter {
    
    private func saveToLocal(_ meals: [MealInfo], with isDataToBeOverwritten: Bool) {
        let queue = DispatchQueue(label: "golovachev-vladislav-SerialQueue", qos: .utility)
        if isDataToBeOverwritten {
            queue.async {
                DataManager.shared.clear()
            }
        }
        queue.asyncAndWait {
            DataManager.shared.persist(meals)
        }
    }
    
    private func downloadPictures(for meals: [MealInfo]) {
        let count = self.getMealCount()
        for (index, meal) in meals.enumerated() {
            NetworkService.shared.downloadPhotoData(by: meal.photoString) { result in
                print("Downloading pictures \(index)")
                switch result {
                case .success(let data):
                    self.updateMealData(index: index + count - 18, data: data) {
                        self.view?.updateList(at: index + count - 18)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    print("IMMM HEEERE")
                }
            }
        }
    }
    
    
    private func updateMealData(index: Int, data: Data?, completion: @escaping () -> Void) {
        let concurrentQueue = DispatchQueue(label: "golovachev-vladislav-ConcurrentQueue",
                                            qos: .utility,
                                            attributes: .concurrent)
        let workItemUpdate = DispatchWorkItem {
            if let data, let compressedData = self.compressedPictureData(of: data) {
                DataManager.shared.updateMeal(of: index,
                                              with: compressedData)
            }
        }
        concurrentQueue.async(execute: workItemUpdate)
        
        workItemUpdate.notify(queue: .main) {
            completion()
        }
    }
    
    private func compressedPictureData(of data: Data) -> Data? {
        return UIImage(data: data)?.jpegData(compressionQuality: 0.6)
    }
}

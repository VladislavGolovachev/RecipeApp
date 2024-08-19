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
    var isDeviceConnectedToInternet: Bool {get}
    func downloadMeals(isDataToBeOverwritten: Bool, shouldAlertBeShown: Bool, viewStateHandler: @escaping () -> Void)
    func getMeal(of number: Int) -> Meal?
    func getMealCount() -> Int
    func goToRecipeScreen(with number: Int, viewStateHandler: @escaping () -> Void)
}

class MealListPresenter: MealListViewPresenterProtocol {
    private let downloadPhotoSemaphore = DispatchSemaphore(value: 8)
    private var isDataResaved = false, isConnectedToInternet = true
    
    weak var view: MealListViewProtocol?
    var router: RouterProtocol?
    var isDeviceConnectedToInternet: Bool {isConnectedToInternet}
    
    required init(view: MealListViewProtocol, router: RouterProtocol) {
        self.view = view
        self.router = router
    }
    
    func downloadMeals(isDataToBeOverwritten: Bool, shouldAlertBeShown: Bool, viewStateHandler: @escaping () -> Void) {
        if isDataToBeOverwritten {
            URLSession.shared.cancelAllTasks()
        }
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
                self.isConnectedToInternet = true
                self.isDataResaved = true
                self.saveToLocal(meals, with: isDataToBeOverwritten)
            } else {
                self.isConnectedToInternet = false
            }
            DispatchQueue.main.async {
                viewStateHandler()
                self.view?.showList()
                self.isDataResaved = false
            }
            if shouldAlertBeShown && !isRequestSuccessful {
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

    func goToRecipeScreen(with number: Int, viewStateHandler: @escaping () -> Void) {
        guard let meal = DataManager.shared.fetchMeal(of: number) else {return}
        URLSession.shared.suspendAllTasks()
        let id = meal.id
        let sharedSession = URLSession.shared
        NetworkService.shared.getMealRecipe(of: id) { [weak self, sharedSession] result in
            sharedSession.resumeAllTasks()
            
            switch result {
            case .success(let mealRecipeResponse):
                guard let mealRecipe = mealRecipeResponse.recipes.first else {return}
                DispatchQueue.main.async {
                    self?.router?.showMealRecipeController(mealRecipe: mealRecipe)
                    viewStateHandler()
                }
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self?.view?.showAlert(message: "Unable to show recipe")
                    viewStateHandler()
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
            downloadPhotoSemaphore.wait()
            NetworkService.shared.downloadPhotoData(by: meal.photoString) { [weak self] result in
                switch result {
                case .success(let data):
                    let ind = index + count - 18
                    self?.updateMealData(index: ind, data: data) { [weak self] in
                        if let isDataResaved = self?.isDataResaved, !isDataResaved {
                            self?.view?.updateList(at: ind)
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
                self?.downloadPhotoSemaphore.signal()
            }
        }
    }
    
    private func updateMealData(index: Int, data: Data?, completion: @escaping () -> Void) {
        let concurrentQueue = DispatchQueue(label: "golovachev-vladislav-ConcurrentQueue",
                                            qos: .utility,
                                            attributes: .concurrent)
        let workItemUpdate = DispatchWorkItem {
            if let data, let compressedData = self.compressedPictureData(of: data) {
                DataManager.shared.updateMeal(of: index, with: compressedData)
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

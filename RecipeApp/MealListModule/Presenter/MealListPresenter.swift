//
//  MealListPresenter.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 25.07.2024.
//

import UIKit

protocol MealListViewProtocol: AnyObject {
    func showList()
    func updateList(at indexPath: IndexPath)
    func showAlertNetworkConnectionError()
}

protocol MealListViewPresenterProtocol: AnyObject {
    init(view: MealListViewController)
    func downloadMeals(isDataToBeOverwritten: Bool)
    func getMeal(of number: Int) -> Meal?
    func didSelectMeal(with id: Int)
}

class MealListPresenter: MealListViewPresenterProtocol {
    
    weak var view: MealListViewProtocol?
    
    required init(view: MealListViewController) {
        self.view = view
    }
    
    func downloadMeals(isDataToBeOverwritten: Bool = true) {
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
        
        group.notify(queue: .global(qos: .userInitiated)) {
            let isRequestSuccessful = !meals.isEmpty

            if isRequestSuccessful {
                self.saveToLocal(meals, with: isDataToBeOverwritten)
            }
            DispatchQueue.main.asyncAndWait {
                self.view?.showList()
            }
            if isRequestSuccessful {
                self.downloadPictures(for: meals)
            }
            
            if !isRequestSuccessful {
                DispatchQueue.main.async {
                    self.view?.showAlertNetworkConnectionError()
                }
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

    func didSelectMeal(with id: Int) {
        print("Go to the next screen")
    }
}

extension MealListPresenter {
    
    private func saveToLocal(_ meals: [MealInfo], with isDataToBeOverwritten: Bool) {
        let queue = DispatchQueue(label: "golovachev-vladislav-SerialQueue", qos: .userInitiated)
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
        print(meals.count, count)
        for (index, meal) in meals.enumerated() {
            NetworkService.shared.downloadPhotoData(by: meal.photoString) { result in
                
                switch result {
                case .success(let data):
                    self.updateMealData(index: index + count - 18, data: data) {
                        self.view?.updateList(at: IndexPath(row: index + count - 18, section: 0))
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func updateMealData(index: Int, data: Data?, completion: @escaping () -> Void) {
        let concurrentQueue = DispatchQueue(label: "golovachev-vladislav-ConcurrentQueue",
                                            qos: .userInitiated,
                                            attributes: .concurrent)
        let workItemUpdate = DispatchWorkItem {
            if let data, let compressedData = self.compressedPictureData(of: data) {
                DataManager.shared.updateMeal(of: index,
                                              with: compressedData)
            }
        }
        concurrentQueue.async(execute: workItemUpdate)
        
        workItemUpdate.notify(queue: .main) {
            let meal = DataManager.shared.fetchMeal(of: index)
            print(index, meal?.photoData)
            completion()
        }
    }
    
    private func compressedPictureData(of data: Data) -> Data? {
        return UIImage(data: data)?.jpegData(compressionQuality: 0.6)
    }
}

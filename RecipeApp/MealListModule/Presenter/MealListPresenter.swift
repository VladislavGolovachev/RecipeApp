//
//  MealListPresenter.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 25.07.2024.
//

import UIKit

protocol MealListViewProtocol: AnyObject{
    func showList()
    func updateList(at indexPath: IndexPath)
}

protocol MealListViewPresenterProtocol: AnyObject {
    init(view: MealListViewController)
    func downloadMeals()
    func getMeal(of number: Int) -> Meal?
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
        
        for _ in 1...40 {
            
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

            if meals.isEmpty {
                DispatchQueue.main.async {
                    self.view?.showList()
                }
            } else {
                let queue = DispatchQueue(label: "golovachev-vladislavQueue", qos: .userInitiated)
                queue.async {
                    DataManager.shared.clear()
                }
                queue.asyncAndWait {
                    DataManager.shared.persist(meals)
                }
                DispatchQueue.main.asyncAndWait {
                    self.view?.showList()
                }
                self.downloadPictures(for: meals)
            }
        }
    }
    
    //FIXME: Fix to have access to local files
    func getMeal(of number: Int) -> Meal? {
        let meal = DataManager.shared.fetchMeal(with: number)
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
    
    private func downloadPictures(for meals: [MealInfo]) {
        for (index, meal) in meals.enumerated() {
            NetworkService.shared.downloadPhotoData(by: meal.photoString) { result in
                
                switch result {
                case .success(let data):
                    self.updateMealData(index: index, data: data) {
                        self.view?.updateList(at: IndexPath(row: index, section: 0))
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func updateMealData(index: Int, data: Data?, completion: @escaping () -> Void) {
        let concurrentQueue = DispatchQueue(label: "concurrentQueue",
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
            completion()
        }
    }
    
    private func compressedPictureData(of data: Data) -> Data? {
        return UIImage(data: data)?.jpegData(compressionQuality: 0.6)
    }
}

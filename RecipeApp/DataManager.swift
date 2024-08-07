//
//  DataManager.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 25.07.2024.
//

import Foundation
import CoreData

protocol CoreDataManagerProtocol {
    func fetchMeal(of number: Int) -> Meal?
    func updateMeal(of number: Int, with data: Data)
    func mealsCount() -> Int
    func persist(_ meals: [MealInfo])
    func clear()
}

final class DataManager {
    static let shared = DataManager()
    private init() {}
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    private lazy var backgroundContext: NSManagedObjectContext = {
        let context = self.persistentContainer.newBackgroundContext()
        context.persistentStoreCoordinator = self.persistentContainer.viewContext.persistentStoreCoordinator
        return context
    }()
}

extension DataManager: CoreDataManagerProtocol {
    
    func fetchMeal(of number: Int) -> Meal? {
        let fetchRequest = Meal.fetchRequest()
        let predicate = NSPredicate(format: "number == %d", number)
        fetchRequest.predicate = predicate
        
        var meal: Meal?
        
        self.backgroundContext.performAndWait {
            do {
                let meals = try self.backgroundContext.fetch(fetchRequest)
                meal = meals.first
            }
            catch {
                print(error.localizedDescription)
            }
        }
        return meal
    }
    
    func persist(_ meals: [MealInfo]) {
        let count = self.mealsCount()
        for (index, meal) in meals.enumerated() {
            self.insert(meal: meal, with: count + index)
        }
        self.backgroundContext.perform {
            do {
                try self.backgroundContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func clear() {
        let fetchRequest = Meal.fetchRequest()
        self.backgroundContext.perform {
            do {
                let meals = try self.backgroundContext.fetch(fetchRequest)
                for meal in meals {
                    self.backgroundContext.delete(meal)
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateMeal(of number: Int, with data: Data) {
        let fetchRequest = Meal.fetchRequest()
        let predicate = NSPredicate(format: "number == %d", number)
        fetchRequest.predicate = predicate

        var meal = [Meal]()
        self.backgroundContext.perform {
            do {
                meal = try self.backgroundContext.fetch(fetchRequest)
                meal.first?.photoData = data
                try self.backgroundContext.save()
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func mealsCount() -> Int {
        let fetchRequest = Meal.fetchRequest()
        var count = 0
        
        self.backgroundContext.performAndWait {
            do {
                count = try self.backgroundContext.count(for: fetchRequest)
            } catch {
                print(error.localizedDescription)
            }
        }

        return count
    }
}

extension DataManager {
    
    private func insert(meal: MealInfo, with number: Int) {
        self.backgroundContext.perform {
            guard let entity = NSEntityDescription.entity(forEntityName: "Meal", in: self.backgroundContext) else {return}
            let mealObject = NSManagedObject(entity: entity, insertInto: self.backgroundContext)
            
            mealObject.setValue(meal.id, forKey: Meal.CodingKeys.id.rawValue)
            mealObject.setValue(meal.name, forKey: Meal.CodingKeys.name.rawValue)
            mealObject.setValue(meal.photoData, forKey: Meal.CodingKeys.photoData.rawValue)
            mealObject.setValue(number, forKey: Meal.CodingKeys.number.rawValue)
        }
    }
}

//
//  DataManager.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 25.07.2024.
//

import Foundation
import CoreData

protocol CoreDataManagerProtocol {
    func fetchMeals() -> [Meal]?
    func persist(_ meals: [MealInfo])
    func clear()
}

final class DataManager {
    static let shared = DataManager()
    private init() {}
    private let persistentContainer = NSPersistentContainer(name: "MealContainer")

    private var _meals: [MealInfo]?
    var meals: [MealInfo]? {
        _meals
    }
    func save(_ meals: [MealInfo]) {
        _meals = meals
    }
}

extension DataManager: CoreDataManagerProtocol {
    private func insert(meal: Meal) {
        let managedObjectContext = self.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Meal", in: managedObjectContext) else {return}
        let mealObject = NSManagedObject(entity: entity, insertInto: managedObjectContext)
        
        mealObject.setValue(meal.id, forKey: Meal.CodingKeys.id.rawValue)
        mealObject.setValue(meal.name, forKey: Meal.CodingKeys.name.rawValue)
        mealObject.setValue(meal.photoData, forKey: Meal.CodingKeys.photoData.rawValue)
        
        do {
            try managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchMeals() -> [Meal]? {
        let managedObjectContext = self.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Meal")
        
        do {
            let meals = try managedObjectContext.fetch(fetchRequest)
            return meals as? [Meal]
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func persist(_ meals: [MealInfo]) {
        
    }
    
    func clear() {
        let managedObjectContext = self.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Meal")
        
        do {
            let meals = try managedObjectContext.fetch(fetchRequest)
            for meal in meals {
                managedObjectContext.delete(meal)
            }
        }
        catch {
            print(error.localizedDescription)
            return
        }
    }
}

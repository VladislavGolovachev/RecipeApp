//
//  Meal+CoreDataProperties.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 25.07.2024.
//
//

import Foundation
import CoreData


extension Meal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Meal> {
        return NSFetchRequest<Meal>(entityName: "Meal")
    }

    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var number: Int32
    @NSManaged public var photoData: Data?

}

extension Meal : Identifiable {

}

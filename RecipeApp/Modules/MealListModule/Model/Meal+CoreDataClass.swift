//
//  Meal+CoreDataClass.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 25.07.2024.
//
//

import Foundation
import CoreData


public class Meal: NSManagedObject {
    enum CodingKeys: String {
        case id = "id"
        case name = "name"
        case photoData = "photoData"
        case number = "number"
    }
}

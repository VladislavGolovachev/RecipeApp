//
//  NetworkService.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 25.07.2024.
//

import Foundation

protocol NetworkServiceProtocol {
    func getRandomMeal(completion: @escaping (Result<MealResponse, Error>) -> Void)
    func getMealRecipe()
}

class NetworkService: NetworkServiceProtocol {
    
    static let shared = NetworkService()
    private init() {}
    
    func getRandomMeal(completion: @escaping (Result<MealResponse, any Error>) -> Void) {
        let urlString = "https://www.themealdb.com/api/json/v1/1/random.php"
        guard let url = URL(string: urlString) else {return}
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error {
                completion(.failure(error))
                return
            }
            
            do {
                if let data {
                    let mealResponse = try JSONDecoder().decode(MealResponse.self, from: data)
                    completion(.success(mealResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }
        dataTask.resume()
    }
    
    func getMealRecipe() {
        
    }
}

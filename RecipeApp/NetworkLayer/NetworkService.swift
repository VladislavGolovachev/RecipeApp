//
//  NetworkService.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 25.07.2024.
//

import Foundation

protocol NetworkAPIRequestsProtocol {
    func getRandomMeal(completion: @escaping (Result<MealResponse, Error>) -> Void)
    func getMealRecipe(of id: String, completion: @escaping (Result<MealRecipeResponse, Error>) -> Void)
}

protocol NetworkDownloadingProtocol {
    func downloadPhotoData(by urlString: String, completion: @escaping (Result<Data?, Error>) -> Void)
}

final class NetworkService {
    static let shared = NetworkService()
    private init() {}
}

extension NetworkService: NetworkAPIRequestsProtocol {
    
    func getRandomMeal(completion: @escaping (Result<MealResponse, Error>) -> Void) {
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
    
    func getMealRecipe(of id: String, completion: @escaping (Result<MealRecipeResponse, Error>) -> Void) {
        let urlString = "https://www.themealdb.com/api/json/v1/1/lookup.php?i=" + id
        guard let url = URL(string: urlString) else {return}
        
        let dataTask = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error {
                completion(.failure(error))
                return
            }
            
            if let data {
                do {
                    let mealRecipeResponse = try JSONDecoder().decode(MealRecipeResponse.self, from: data)
                    completion(.success(mealRecipeResponse))
                    
                } catch {
                    completion(.failure(error))
                }
            }
        }
        dataTask.resume()
    }
}

extension NetworkService: NetworkDownloadingProtocol {
    func downloadPhotoData(by urlString: String, completion: @escaping (Result<Data?, Error>) -> Void) {
        guard let url = URL(string: urlString) else {return}
        let dataTask = URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error  {
                completion(.failure(error))
                return
            }
            completion(.success(data))
        }
        dataTask.resume()
    }
}

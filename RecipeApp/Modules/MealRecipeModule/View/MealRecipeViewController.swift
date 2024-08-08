//
//  MealRecipeViewController.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 08.08.2024.
//

import UIKit
import WebKit

class MealRecipeViewController: UIViewController {
    
    var presenter: MealRecipeViewPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .yellow
        print(self.presenter!.getMealRecipe())
        let webView = WKWebView(frame: CGRectZero)
    }
}

///name
///category
///area
///instruction
///ingredients

//
//  MealRecipeViewController.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 08.08.2024.
//

import UIKit
import WebKit

class MealRecipeViewController: UIViewController {
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = MealRecipeConstants.Color.background
        return scrollView
    }()
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .fill
        stackView.backgroundColor = MealRecipeConstants.Color.background
        return stackView
    }()
    lazy var nameLabel: UILabel = {
        let label = UILabel(text: self.presenter?.getMealAttribute(.name),
                            fontSize: MealRecipeConstants.Font.Size.title.rawValue,
                            color: MealRecipeConstants.Color.text)
        label.textAlignment = .center
        return label
    }()
    lazy var areaLabel = UILabel(text: (self.presenter?.getMealAttribute(.area) ?? "") + " dish",
                                 fontSize: MealRecipeConstants.Font.Size.text.rawValue,
                                 color: MealRecipeConstants.Color.text)
    lazy var categoryLabel = UILabel(text: "Category: " + (self.presenter?.getMealAttribute(.category) ?? ""),
                                     fontSize: MealRecipeConstants.Font.Size.text.rawValue,
                                     color: MealRecipeConstants.Color.text)
    let instructionsLabel = UILabel(text: "Instructions:",
                                    fontSize: MealRecipeConstants.Font.Size.text.rawValue,
                                    color: MealRecipeConstants.Color.text)
    let ingredientsLabel = UILabel(text: "Ingredients:",
                                   fontSize: MealRecipeConstants.Font.Size.text.rawValue,
                                   color: MealRecipeConstants.Color.text)
    let sourceLabel = UILabel(text: "Source:",
                              fontSize: MealRecipeConstants.Font.Size.text.rawValue,
                              color: MealRecipeConstants.Color.text)
    lazy var linkLabel: UILabel = {
        let label = UILabel(text: self.presenter?.getSourceLink(),
                            fontSize: MealRecipeConstants.Font.Size.link.rawValue,
                            color: MealRecipeConstants.Color.link)
        label.numberOfLines = 2
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(linkLabelTap(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        label.addGestureRecognizer(tapGestureRecognizer)
        label.isUserInteractionEnabled = true
        
        return label
    }()
    lazy var instructionTextView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        textView.textColor = MealRecipeConstants.Color.text
        textView.backgroundColor = MealRecipeConstants.Color.background
        
        var text = ""
        if let instruction = self.presenter?.getMealAttribute(.instruction) {
            text += instruction
        }
        textView.text = text
        
        return textView
    }()
    lazy var ingredientsTextView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        textView.textColor = MealRecipeConstants.Color.text
        textView.backgroundColor = MealRecipeConstants.Color.background
        textView.text = self.presenter?.getMealIngredientsString()
        
        return textView
    }()
    
    var presenter: MealRecipeViewPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = MealRecipeConstants.Color.background
        
        self.addSubviews()
        self.presenter?.checkSourceLinkExistence()
        stackView.setCustomSpacing(5, after: instructionsLabel)
        stackView.setCustomSpacing(5, after: ingredientsLabel)
        self.setupConstraints()
    }
}

extension MealRecipeViewController {
    private func addSubviews() {
        self.view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(areaLabel)
        stackView.addArrangedSubview(categoryLabel)
        stackView.addArrangedSubview(instructionsLabel)
        stackView.addArrangedSubview(instructionTextView)
        stackView.addArrangedSubview(ingredientsLabel)
        stackView.addArrangedSubview(ingredientsTextView)
    }
    
    private func setupConstraints() {
        let safeAreaGuide = self.view.safeAreaLayoutGuide
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeAreaGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaGuide.trailingAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1.0)
        ])
    }
}

extension MealRecipeViewController {
    @objc func linkLabelTap(_ sender: UILabel) {
        self.presenter?.loadLink()
    }
}

extension MealRecipeViewController: MealRecipeViewProtocol {
    func showSourceLink() {
        stackView.addArrangedSubview(sourceLabel)
        stackView.addArrangedSubview(linkLabel)
        stackView.setCustomSpacing(5, after: sourceLabel)
        stackView.setCustomSpacing(0, after: ingredientsTextView)
    }
}

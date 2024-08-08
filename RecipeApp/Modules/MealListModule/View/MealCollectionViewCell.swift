//
//  MealCollectionViewCell.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 26.07.2024.
//

import UIKit

class MealCollectionViewCell: UICollectionViewCell {
    var label = UILabel()
    var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(label)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.imageView.topAnchor.constraint(equalTo: self.topAnchor),
            self.imageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.92),
            self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.label.topAnchor.constraint(equalTo: self.imageView.bottomAnchor)
        ])
        
        let wholeSize = CGFloat(Int(frame.size.height * 0.07))
        self.label.font = self.label.font.withSize(wholeSize)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.imageView.image = nil
    }
}

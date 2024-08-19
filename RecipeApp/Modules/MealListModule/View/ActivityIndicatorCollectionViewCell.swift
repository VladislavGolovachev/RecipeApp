//
//  ActivityIndicatorCollectionViewCell.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 11.08.2024.
//

import UIKit

class ActivityIndicatorCollectionViewCell: UICollectionViewCell {
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.color = .lightGray
        activityIndicator.style = .medium
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = true
        return activityIndicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        self.contentView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

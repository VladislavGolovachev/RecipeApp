//
//  ViewController.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 23.07.2024.
//

import UIKit

class MealListViewController: UIViewController {

    var presenter: MealListPresenter?
    var cellSize: CGSize?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.backgroundColor = .black
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.refreshControl = refreshControl
        
        collectionView.register(MealCollectionViewCell.self, forCellWithReuseIdentifier: "Recipe")
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.view.addSubview(collectionView)
        setupConstraints()
        
        self.collectionView.isHidden = true
        self.presenter?.downloadMeals()
    }
    
    override func viewDidLayoutSubviews() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return}
        let widthPerItem = Int((collectionView.frame.width - layout.minimumInteritemSpacing
                                - layout.sectionInset.left - layout.sectionInset.right) / 2.0)
        
        if cellSize == nil {
            cellSize = CGSize(width: widthPerItem, height: widthPerItem)
        }
    }
}

//MARK: Constraints
extension MealListViewController {
    
    func setupConstraints() {
        let safeArea = self.view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            self.collectionView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])
    }
    
    @objc func refreshAction(_ sender: UIRefreshControl) {
        self.presenter?.downloadMeals()
        sender.endRefreshing()
    }
}

extension MealListViewController: UICollectionViewDataSource {
    
    //FIXME: Needs to change number of rows
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.presenter?.getMealCount() ?? 0
    }
    
    //FIXME: Needs to implement UICollectionViewCell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Recipe", for: indexPath)
        as? MealCollectionViewCell ?? MealCollectionViewCell()
        
        if let meal = self.presenter?.getMeal(of: indexPath.row) {
            cell.label.text = meal.name
            cell.label.textColor = .white
            cell.label.textAlignment = .center
            if let data = meal.photoData {
                cell.imageView.image = UIImage(data: data)
            }
        }
        
        return cell
    }
}

extension MealListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return cellSize ?? CGSizeZero
    }
}

extension MealListViewController: MealListViewProtocol {
    
    func showList() {
        self.collectionView.reloadData()
        self.collectionView.isHidden = false
    }
    
    func updateList(at indexPath: IndexPath) {
        self.collectionView.reloadItems(at: [indexPath])
    }
    
    func showAlertNetworkConnectionError() {
        let alert = UIAlertController(title: "No network connection",
                                      message: "Connect your device to the network to be able to load new meals",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        self.present(alert, animated: true)
    }
}

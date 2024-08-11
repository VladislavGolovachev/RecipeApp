//
//  ViewController.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 23.07.2024.
//

import UIKit

class MealListViewController: UIViewController {

    var presenter: MealListViewPresenterProtocol?
    var cellSize: CGSize?
    var isUpdatingUI = false
    var isRefreshing = false
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.backgroundColor = MealListConstants.Color.background
        collectionView.isHidden = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = MealListConstants.Color.refreshControl
        refreshControl.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.refreshControl = refreshControl
        
        collectionView.register(MealCollectionViewCell.self, forCellWithReuseIdentifier: "Meal")
        collectionView.register(ActivityIndicatorCollectionViewCell.self, forCellWithReuseIdentifier: "ActivityIndicator")
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = MealListConstants.Color.background
        self.view.addSubview(collectionView)
        setupConstraints()
        
        self.presenter?.downloadMeals(isDataToBeOverwritten: true, isAlertShouldBeShown: true) {}
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
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.collectionView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])
    }
    
    @objc func refreshAction(_ sender: UIRefreshControl) {
        if isRefreshing {
            return
        }
        isRefreshing = true
        URLSession.shared.cancelAllTasks()
        self.presenter?.downloadMeals(isDataToBeOverwritten: true, isAlertShouldBeShown: true) { [weak self] in
            self?.isRefreshing = false
            sender.endRefreshing()
        }
    }
}

extension MealListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.presenter?.getMealCount() ?? -1) + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == self.presenter?.getMealCount() {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActivityIndicator", for: indexPath)
            as? ActivityIndicatorCollectionViewCell ?? ActivityIndicatorCollectionViewCell()
            cell.activityIndicator.startAnimating()
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Meal", for: indexPath)
        as? MealCollectionViewCell ?? MealCollectionViewCell()
        
        if let meal = self.presenter?.getMeal(of: indexPath.row) {
            cell.label.text = meal.name
            cell.label.textColor = MealListConstants.Color.text
            cell.label.textAlignment = .center
            if let data = meal.photoData {
                cell.imageView.image = UIImage(data: data)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        self.presenter?.goToRecipeScreen(with: index)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.row + 2 == self.presenter!.getMealCount() + 1 else {return}
        
        print(indexPath)
    }
}

extension MealListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == self.presenter?.getMealCount() {
            return CGSize(width: collectionView.contentSize.width, height: 40)
        }
        return cellSize ?? CGSizeZero
    }
}

extension MealListViewController: MealListViewProtocol {
    
    func showList() {
        self.collectionView.reloadData()
        self.collectionView.isHidden = false
    }
    
    func updateList(at row: Int) {
        let indexPath = IndexPath(row: row, section: 0)
        self.collectionView.reloadItems(at: [indexPath])
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Loading error",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true)
    }
}

extension MealListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if isUpdatingUI {
            return
        }
        guard let maxRow = indexPaths.max(by: {$0.row < $1.row})?.row else {return}
        let count = self.presenter?.getMealCount() ?? maxRow
        
        if maxRow >= count - 3 {
            isUpdatingUI = true
            print("NewCells")
            self.presenter?.downloadMeals(isDataToBeOverwritten: false, isAlertShouldBeShown: false) { [weak self] in
                self?.isUpdatingUI = false
            }
        }
    }
}

//
//  ViewController.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 23.07.2024.
//

import UIKit

class MealListViewController: UIViewController {
    var presenter: MealListViewPresenterProtocol?
    private var cellSize: CGSize?
    private var viewState = ViewState.none
    private var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        
        return activityIndicator
    }()
    
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
        self.view.addSubview(activityIndicator)
        setupConstraints()
        
        viewState = .updating
        self.presenter?.downloadMeals(isDataToBeOverwritten: true, shouldAlertBeShown: true) { [weak self] in
            self?.viewState = .none
        }
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

//MARK: Private functions
extension MealListViewController {
    
    private func setupConstraints() {
        let safeArea = self.view.safeAreaLayoutGuide

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.collectionView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])
    }
    
    @objc private func refreshAction(_ sender: UIRefreshControl) {
        if viewState.rawValue >= ViewState.refreshing.rawValue {
            return
        }
        
        viewState = .refreshing
        self.presenter?.downloadMeals(isDataToBeOverwritten: true, shouldAlertBeShown: true) { [weak self] in
            self?.viewState = .none
            sender.endRefreshing()
        }
    }
    
    private func deactivateActivityIndicatorCell() {
        guard let count = self.presenter?.getMealCount(),
              let cell = collectionView.cellForItem(at: IndexPath(row: count -  18, section: 0)) as? ActivityIndicatorCollectionViewCell else {return}
        cell.activityIndicator.stopAnimating()
    }
}

//MARK: UICollectionViewDelegate
extension MealListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if viewState == .presenting {
            return
        }
        viewState = .presenting
        
        guard let cell = collectionView.cellForItem(at: indexPath) else {return}
        let centerInParentsView = collectionView.convert(cell.center, to: view)
        activityIndicator.center = centerInParentsView
        
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.5) {
            cell.alpha = 0.4
        }
        UIView.animate(withDuration: 0.5) {
            cell.alpha = 1
        }
        
        let index = indexPath.row
        self.presenter?.goToRecipeScreen(with: index) { [weak self] in
            self?.viewState = .none
            self?.activityIndicator.stopAnimating()
            self?.view.isUserInteractionEnabled = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row != collectionView.numberOfItems(inSection: 0) - 1 || viewState != .none {
            return
        }
        viewState = .updating
        self.presenter?.downloadMeals(isDataToBeOverwritten: false, shouldAlertBeShown: false) { [weak self] in
            self?.deactivateActivityIndicatorCell()
            self?.viewState = .none
        }
    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension MealListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == collectionView.numberOfItems(inSection: 0) - 1 {
            return CGSize(width: collectionView.contentSize.width, height: 40)
        }
        return cellSize ?? CGSizeZero
    }
}

//MARK: UICollectionViewDataSource
extension MealListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.presenter?.getMealCount() ?? 0) + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == collectionView.numberOfItems(inSection: 0) - 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActivityIndicator", for: indexPath)
            as? ActivityIndicatorCollectionViewCell ?? ActivityIndicatorCollectionViewCell()
            if let isConnectedToInternet = self.presenter?.isDeviceConnectedToInternet, isConnectedToInternet {
                cell.activityIndicator.startAnimating()
            }
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
}

//MARK: UICollectionViewDataSourcePrefetching
extension MealListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if viewState != .none {
            return
        }
        guard let maxRow = indexPaths.max(by: {$0.row < $1.row})?.row else {return}
        let count = collectionView.numberOfItems(inSection: 0)
        
        if maxRow >= count - 3 {
            viewState = .updating
            self.presenter?.downloadMeals(isDataToBeOverwritten: false, shouldAlertBeShown: false) { [weak self] in
                self?.deactivateActivityIndicatorCell()
                self?.viewState = .none
            }
        }
    }
}

//MARK: MealListViewProtocol
extension MealListViewController: MealListViewProtocol {
    func showList() {
        collectionView.reloadData()
        collectionView.isHidden = false
    }
    
    func updateList(at row: Int) {
        let indexPath = IndexPath(row: row, section: 0)
        collectionView.reloadItems(at: [indexPath])
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Loading error",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true)
    }
}

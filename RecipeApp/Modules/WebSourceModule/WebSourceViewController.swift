//
//  WebSourceViewController.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 09.08.2024.
//

import UIKit
import WebKit

class WebSourceViewController: UIViewController {

    lazy private var webView: WKWebView = {
        return WKWebView()
    }()
    var link: String
    
    init(link: String) {
        self.link = link
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.view.addSubview(webView)
        
        setupConstraints()
        loadWeb()
    }
}

extension WebSourceViewController {
    private func setupConstraints() {
        let safeArea = self.view.safeAreaLayoutGuide
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
    private func loadWeb() {
        guard let url = URL(string: link) else {return}
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

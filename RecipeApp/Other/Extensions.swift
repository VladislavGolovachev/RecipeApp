//
//  Extensions.swift
//  RecipeApp
//
//  Created by Владислав Головачев on 09.08.2024.
//

import UIKit

extension UILabel {
    convenience init(text: String?, fontSize: CGFloat, color: UIColor) {
        self.init()
        self.text = text
        self.font = self.font.withSize(fontSize)
        self.textColor = color
    }
}

extension URLSession {
    
    func resumeAllTasks() {
        URLSession.shared.getAllTasks {tasks in
            tasks.forEach {$0.resume()}
        }
    }
    
    func cancelAllTasks() {
        URLSession.shared.getAllTasks {tasks in
            tasks.forEach {$0.cancel()}
        }
    }
    
    func suspendAllTasks() {
        URLSession.shared.getAllTasks {tasks in
            tasks.forEach {$0.suspend()}
        }
    }
}

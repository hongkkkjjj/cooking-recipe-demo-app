//
//  ReportRecipeViewController.swift
//  Easy Cook
//
//  Created by Kua Jun Hong on 03/12/2020.
//

import UIKit

class ReportRecipeViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var reasonTextView: UITextView!
    
    // MARK: - Variable declaration
    
    internal var recipeId = 0
    internal var dismissCompletion: (() -> Void)? = nil
    
    // MARK: - Override func
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapGesture()
        contentView.layer.cornerRadius = 8
        reasonTextView.layer.borderWidth = 1
        reasonTextView.layer.cornerRadius = 8
    }
    
    // MARK: - Private func
    
    private func setupTapGesture() {
        let hideGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissController))
        
        tapGesture.delegate = self
        
        self.view.addGestureRecognizer(hideGesture)
        self.view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Objc func
    
    @objc private func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - IBAction
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismissController()
    }
    
    @IBAction func confirmButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.dismissCompletion?()
        })
    }
}

extension ReportRecipeViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
         if touch.view?.isDescendant(of: contentView) == true {
            return false
         }
         return true
    }
}

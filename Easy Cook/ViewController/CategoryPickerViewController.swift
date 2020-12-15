//
//  CategoryPickerViewController.swift
//  Easy Cook
//
//  Created by Kua Jun Hong on 09/12/2020.
//

import UIKit
import SWXMLHash

class CategoryPickerViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var categoryImageView: UIImageView!
    
    // MARK: - Variable declaration
    
    private var typeList: [String] = []
    private var category = ""
    internal var delegate : CategoryPickerVCDelegate?
    
    // MARK: - Override func
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryImageView.image = UIImage(named: "soup")
        
        if let path = Bundle.main.url(forResource: "recipeType", withExtension: "xml") {
            let data = try! Data(contentsOf: path)
            if let strText = String(data: data, encoding: .utf8) {
                let xml = SWXMLHash.parse(strText)
                for elem in xml["recipetype"]["type"].all {
                    typeList.append(elem.element?.text ?? "")
                }
            }
            self.category = typeList[0]
        }
        
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.reloadAllComponents()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Objc func
    
    @objc private func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - IBAction
    
    @IBAction func okButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            if self.delegate != nil {
                self.delegate?.getCategoryFromPicker(str: self.category)
            }
        })
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CategoryPickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return typeList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
           return typeList[row]
       }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var imageName = "dessert"
        switch row {
        case 0:
            imageName = "soup"
        case 1:
            imageName = "meat"
        case 2:
            imageName = "salad"
        case 3:
            imageName = "pasta"
        default:
            imageName = "dessert"
        }
        
        self.categoryImageView.image = UIImage(named: imageName)
        self.category = typeList[row]
    }
}

extension CategoryPickerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
         if touch.view?.isDescendant(of: contentView) == true || touch.view?.isDescendant(of: bottomView) == true {
            return false
         }
         return true
    }
}

protocol CategoryPickerVCDelegate {
    func getCategoryFromPicker(str: String)
}

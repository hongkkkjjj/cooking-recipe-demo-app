//
//  RecipeEditViewController.swift
//  Easy Cook
//
//  Created by Kua Jun Hong on 10/12/2020.
//

import UIKit
import DropDown
import SDWebImage
import AVFoundation

class RecipeEditViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var recipeNameTextField: UITextField!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var categoryDropDownView: UIView!
    @IBOutlet weak var categoryDropDownButton: UIButton!
    @IBOutlet weak var ingredientTableView: UITableView!
    @IBOutlet weak var addIngredientButton: UIButton!
    @IBOutlet weak var minusIngredientButton: UIButton!
    @IBOutlet weak var stepTableView: UITableView!
    @IBOutlet weak var addStepButton: UIButton!
    @IBOutlet weak var minusStepButton: UIButton!
    @IBOutlet weak var deleteButtonView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var ingredientTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var stepTableViewHeight: NSLayoutConstraint!
    
    // MARK: - Variable declaration
    
    internal var selectedRecipe = RecipeDetail()
    internal var editOrAdd = 0 /// 0 is edit, 1 is add
    private let catDropDown = DropDown()
    private var stepCount = 1
    private var ingredientCount = 1
    private var stepList: [String] = []
    private var ingredientList: [String] = []
    private var imagePicker: UIImagePickerController!
    private var base64ImageString: String = ""
    
    // MARK: - Override func
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hideGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(hideGesture)
        hideGesture.cancelsTouchesInView = false
        
        addObserver()
        setupView()
        setupDropDown()
        addTableViewDelegate()
        if editOrAdd == 0 {
            ingredientList = selectedRecipe.ingredients
            ingredientCount = selectedRecipe.ingredients.count
            stepList = selectedRecipe.steps
            stepCount = selectedRecipe.steps.count
            setupRecipeDetail()
        } else {
            stepList.append("")
            ingredientList.append("")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let tableView = object as? UITableView, tableView == ingredientTableView, keyPath! == "contentSize" {
            self.ingredientTableViewHeight.constant = Util.getTableViewHeightMethod(tableView: self.ingredientTableView)
        } else if let tableView = object as? UITableView, tableView == stepTableView, keyPath! == "contentSize" {
            self.stepTableViewHeight.constant = Util.getTableViewHeightMethod(tableView: self.stepTableView)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editToRecipeDetail" {
            if let vc = segue.destination as? RecipeDetailsViewController {
                vc.recipeDetail = selectedRecipe
                vc.afterAdd = true
            }
        }
    }
    
    deinit {
        print("deinit")
        ingredientTableView.removeObserver(self, forKeyPath: "contentSize")
        stepTableView.removeObserver(self, forKeyPath: "contentSize")
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillChangeFrameNotification)
    }
    
    // MARK: - Private func
    
    private func setupView() {
        deleteButtonView.isHidden = editOrAdd == 1
        deleteButton.layer.cornerRadius = 10
        categoryDropDownView.layer.cornerRadius = 10
        categoryDropDownView.dropShadow()
        recipeImageView.layer.cornerRadius = 5
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showCameraOption))
        recipeImageView.addGestureRecognizer(tapGesture)
    }
    
    private func setupRecipeDetail() {
        recipeNameTextField.text = selectedRecipe.name
        categoryDropDownButton.setTitle(selectedRecipe.category, for: .normal)
        if selectedRecipe.image.contains("https"), let url = URL(string: selectedRecipe.image) {
            recipeImageView.sd_setImage(with: url, completed: nil)
        } else {
            if !selectedRecipe.image.isEmpty, let data = selectedRecipe.image.fromBase64() {
                recipeImageView.image = UIImage(data: data)
            }
        }
    }
    
    private func addObserver() {
        ingredientTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        stepTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    private func setupDropDown() {
        let categories = FMDBDatabaseModel.getUniqueCategoryType()
        DropDown.appearance().cornerRadius = 8
        DropDown.appearance().textFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        catDropDown.anchorView         = categoryDropDownView
        catDropDown.dismissMode        = .onTap
        catDropDown.direction          = .any
        catDropDown.dataSource         = categories
        catDropDown.selectRow(at: 0)
        catDropDown.bottomOffset       = CGPoint(x: 0, y:(catDropDown.anchorView?.plainView.bounds.height)!)
        catDropDown.selectionAction    = { [unowned self] (index: Int, item: String) in
                categoryDropDownButton.setTitle(item, for: .normal)
        }
    }
    
    private func addTableViewDelegate() {
        ingredientTableView.delegate = self
        ingredientTableView.dataSource = self
        stepTableView.delegate = self
        stepTableView.dataSource = self
    }
    
    private func backToDetailAfterEdit() {
        DispatchQueue.main.async {
            if let vc = self.navigateBackToViewController(RecipeDetailsViewController.self, animated: true) as? RecipeDetailsViewController {
                vc.refreshDetail()
            }
        }
    }
    
    private func backToDetailAfterAdd() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "editToRecipeDetail", sender: nil)
        }
    }
    
    // MARK: - Objc func
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            mainScrollView.contentInset = .zero
        } else {
            mainScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        mainScrollView.scrollIndicatorInsets = mainScrollView.contentInset
    }
    
    @objc func showCameraOption() {
        let action1 = UIAlertAction(title: "Camera", style: .default, handler: {_ in
            self.takePhoto(decision: 1)
        })
        let action2 = UIAlertAction(title: "Photo Library", style: .default, handler: {_ in
            self.takePhoto(decision: 2)
        })
        let action3 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        Util.showAlertController(message: "Select image from", alertActions: [action1, action2, action3], vc: self)
    }

    // MARK: - IBAction
    
    @IBAction func categoryDropDownAction(_ sender: Any) {
        catDropDown.show()
    }

    @IBAction func addIngredientButtonAction(_ sender: Any) {
        ingredientCount += 1
        ingredientList.append("")
        ingredientTableView.reloadData()
    }
    
    @IBAction func minusIngredientButtonAction(_ sender: Any) {
        ingredientCount -= 1
        if ingredientCount >= 0 {
            ingredientList.removeLast()
        } else {
            ingredientCount = 0
        }
        ingredientTableView.reloadData()
    }
    
    @IBAction func addStepsButtonAction(_ sender: Any) {
        stepCount += 1
        stepList.append("")
        stepTableView.reloadData()
    }
    
    @IBAction func minusStepButtonAction(_ sender: Any) {
        stepCount -= 1
        if stepCount  >= 0 {
            stepList.removeLast()
        } else {
            stepCount = 0
        }
        
        stepTableView.reloadData()
    }
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        let action1 = UIAlertAction(title: "OK", style: .default, handler: {_ in
            if let vc = self.navigateBackToViewController(TabBarViewController.self, animated: true) {
                if FMDBDatabaseModel.removeRecipe(rid: self.selectedRecipe.id) {
                    print("Delete recipe")
                }
            }
            
        })
        let action2 = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        Util.showAlertController(message: "Are you sure that you want to delete this recipe?", alertActions: [action1, action2], vc: self)
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        view.endEditing(true)
        
        guard let name = recipeNameTextField.text?.trimString(), !name.isEmpty else {
            Util.showNormalAlertController(message: "Recipe title cannot be empty.", vc: self)
            return
        }
        
        if editOrAdd == 1 {
            guard !base64ImageString.isEmpty else {
                Util.showNormalAlertController(message: "Recipe image cannot be empty.", vc: self)
                return
            }
        }
        
        guard let cat = categoryDropDownButton.titleLabel?.text, cat != "Please select" else {
            Util.showNormalAlertController(message: "Recipe category cannot be empty.", vc: self)
            return
        }
        
        guard ingredientCount > 0 else {
            Util.showNormalAlertController(message: "Ingredient cannot be empty.", vc: self)
            return
        }
        
        let ingredientArr = ingredientList.filter {!$0.trimString().isEmpty}
        guard ingredientArr.count > 0 else {
            Util.showNormalAlertController(message: "Ingredient cannot be empty.", vc: self)
            return
        }
        
        guard stepCount > 0 else {
            Util.showNormalAlertController(message: "Step cannot be empty.", vc: self)
            return
        }
        
        let stepArr = stepList.filter {!$0.trimString().isEmpty}
        guard stepArr.count > 0 else {
            Util.showNormalAlertController(message: "Step cannot be empty.", vc: self)
            return
        }
        
        let diff = selectedRecipe.steps.count - stepArr.count
        
        selectedRecipe.name = name
        selectedRecipe.category = cat
        selectedRecipe.steps = stepArr
        selectedRecipe.ingredients = ingredientArr
        
        if editOrAdd == 0 {
            // update existing
            
            if !base64ImageString.isEmpty {
                selectedRecipe.image = base64ImageString
            }
            
            if FMDBDatabaseModel.updateRecipeDetail(recipe: selectedRecipe, stepDiff: diff) {
                let action = UIAlertAction(title: "OK", style: .default, handler: {_ in
                    self.backToDetailAfterEdit()
                })
                Util.showAlertController(message: "Successfully updated the recipe.", alertActions: [action], vc: self)
            } else {
                let action = UIAlertAction(title: "OK", style: .default, handler: {_ in
                    self.backToDetailAfterEdit()
                })
                Util.showAlertController(message: "Update recipe is not successful.", alertActions: [action], vc: self)
            }
        } else {
            selectedRecipe.image = base64ImageString
            let rid = FMDBDatabaseModel.insertNewData(recipe: selectedRecipe)
            if rid != 0 {
                selectedRecipe.id = rid
                let action = UIAlertAction(title: "OK", style: .default, handler: {_ in
                    self.backToDetailAfterAdd()
                })
                Util.showAlertController(message: "Successfully added the recipe.", alertActions: [action], vc: self)
            } else {
                let action = UIAlertAction(title: "OK", style: .default, handler: {_ in
                    self.navigationController?.popViewController(animated: true)
                })
                Util.showAlertController(message: "Add recipe is not successful.", alertActions: [action], vc: self)
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension RecipeEditViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == stepTableView {
            return stepCount
        } else if tableView == ingredientTableView {
            return ingredientCount
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == ingredientTableView {
            if let cell = ingredientTableView.dequeueReusableCell(withIdentifier: "IngredientsTableViewCell", for: indexPath) as? IngredientsTableViewCell {
                
                cell.ingredientTextField.text = ingredientList[indexPath.row]
                cell.ingredientTextField.tag = 200 + indexPath.row
                cell.ingredientTextField.delegate = self
                
                return cell
            }
        } else if tableView == stepTableView {
            if let cell = stepTableView.dequeueReusableCell(withIdentifier: "StepsTableViewCell", for: indexPath) as? StepsTableViewCell {
                
                cell.stepTextView.text = stepList[indexPath.row]
                cell.stepTextView.tag = 100 + indexPath.row
                cell.stepTextView.delegate = self
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
}

// MARK: - UITextFieldDelegate

extension RecipeEditViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        let rowIndex = textField.tag - 200
        let rawStr = textField.text?.trimString() ?? ""
        ingredientList[rowIndex] = rawStr
    }
}

// MARK: - UITextViewDelegate

extension RecipeEditViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        let rowIndex = textView.tag - 100
        let rawStr = textView.text.trimString()
        stepList[rowIndex] = rawStr
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension RecipeEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func takePhoto(decision: Int) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        if decision == 1 {
            let cameraMediaType = AVMediaType.video
            let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)

            let action1 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let action2 = UIAlertAction(title: "Go settings", style: .default, handler: {_ in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })

            switch cameraAuthorizationStatus {
            case .denied, .restricted:
                Util.showAlertController(message: "Please turn on permission of camera.", alertActions: [action1, action2], vc: self)
                break
            case .authorized:
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
                break
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (choice) in
                    if choice {
                        DispatchQueue.main.async(execute: {
                            self.imagePicker.sourceType = .camera
                            self.present(self.imagePicker, animated: true, completion: nil)
                        })
                    } else {
                        Util.showAlertController(message: "Please turn on permission of camera.", alertActions: [action1, action2], vc: self)
                    }
                })
            default:
                break
            }

        } else {
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.modalPresentationStyle = .fullScreen
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
            
        if let captureImage = info[.originalImage] as? UIImage,
            let tempData = captureImage.jpegData(compressionQuality: 0.0) {

            base64ImageString = tempData.base64EncodedString()
            recipeImageView.image = UIImage(data: tempData)
        }
    }
}

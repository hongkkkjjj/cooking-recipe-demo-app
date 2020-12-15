//
//  RecipeDetailsViewController.swift
//  Easy Cook
//
//  Created by Kua Jun Hong on 03/12/2020.
//

import UIKit
import SDWebImage

class RecipeDetailsViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var totalLikesLabel: UILabel!
    @IBOutlet weak var recipeCategoryLabel: UILabel!
    @IBOutlet weak var ingredientListLabel: UILabel!
    @IBOutlet weak var stepListLabel: UILabel!
    @IBOutlet weak var reportRecipeButton: UIButton!
    
    // MARK: - Variable Declaration
    
    private var likeCount = 0
    internal var recipeDetail = RecipeDetail()
    internal var isFavorRecipe: Bool = false
    internal var afterAdd: Bool = false
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        if afterAdd {
            self.navigationItem.hidesBackButton = true
            let button = UIButton(type: .system)
            button.setTitle("Back", for: .normal)
            let config = UIImage.SymbolConfiguration(pointSize: 17.0, weight: .bold)
            button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
            button.addTarget(self, action: #selector(back(sender:)), for: .touchUpInside)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailToEdit" {
            if let vc = segue.destination as? RecipeEditViewController {
                vc.selectedRecipe = self.recipeDetail
            }
        }
    }
    
    // MARK: - Private func
    
    private func setupView() {
        if !isFavorRecipe {
            // check db here
            isFavorRecipe = FMDBDatabaseModel.checkIsFavorRecipe(rid: recipeDetail.id)
        }
        
        setupButtonAttributedText()
        
        recipeNameLabel.text = recipeDetail.name
        recipeImageView.layer.cornerRadius = 5
        if recipeDetail.image.contains("https:"), let url = URL(string: recipeDetail.image) {
            recipeImageView.sd_setImage(with: url, completed: nil)
        } else {
            if let data = recipeDetail.image.fromBase64() {
                recipeImageView.image = UIImage(data: data)
            }
        }
        let image = isFavorRecipe ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        favouriteButton.setImage(image, for: .normal)
        likeCount = recipeDetail.likes
        totalLikesLabel.text = "\(likeCount) likes"
        recipeCategoryLabel.text = recipeDetail.category
        var ingredientText = ""
        for ingredient in recipeDetail.ingredients {
            ingredientText += "\u{2022} \(ingredient)\n\n"
        }
        ingredientListLabel.text = ingredientText
        var stepText = ""
        for i in 1 ... recipeDetail.steps.count {
            stepText += "\(i). \(recipeDetail.steps[i-1])\n\n"
        }
        stepListLabel.text = stepText
    }
    
    private func setupButtonAttributedText() {
        let attributes: [NSAttributedString.Key : Any] = [
            .underlineStyle : NSUnderlineStyle.single.rawValue,
            .foregroundColor : UIColor.lightGray,
            .font : UIFont.systemFont(ofSize: 15, weight: .semibold)
        ]
        let attributedText = NSAttributedString(string: "Report recipe?", attributes: attributes)
        reportRecipeButton.setAttributedTitle(attributedText, for: .normal)
    }
    
    private func refreshRecipeDetail() {
        if let recipe = FMDBDatabaseModel.getSelectedRecipe(rid: self.recipeDetail.id) {
            self.recipeDetail = recipe
            setupView()
        }
    }
    
    // MARK: - Objc func
    
    @objc private func back(sender: UIBarButtonItem) {
        if let vc = self.navigateBackToViewController(TabBarViewController.self, animated: true) {
            print("Go back to main menu")
        }
    }
    
    // MARK: - Internal func
    
    internal func refreshDetail() {
        refreshRecipeDetail()
    }

    // MARK: - IBAction
    
    @IBAction func favouriteButtonAction(_ sender: Any) {
        let image = isFavorRecipe ? UIImage(systemName: "heart") : UIImage(systemName: "heart.fill")
        favouriteButton.setImage(image, for: .normal)
        likeCount = isFavorRecipe ? likeCount - 1 : likeCount + 1
        totalLikesLabel.text = "\(likeCount) likes"
        isFavorRecipe = !isFavorRecipe
        // update db
        let success = FMDBDatabaseModel.updateRecipeViewAndLike(id: recipeDetail.id, type: .likes, value: likeCount, addFavor: isFavorRecipe)
        print("Update like success: \(success)")
    }
    
    @IBAction func reportRecipeAction(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "reportRecipeViewController") as? ReportRecipeViewController {
            vc.recipeId = self.recipeDetail.id
            vc.dismissCompletion = {
                if FMDBDatabaseModel.removeRecipe(rid: self.recipeDetail.id) {
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: {_ in
                        self.navigationController?.popViewController(animated: true)
                    })
                    
                    Util.showAlertController(message: "Thank you for your contribution. We will temporarily removed this recipe and review it.", alertActions: [okAction], vc: self)
                } else {
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    
                    Util.showAlertController(message: "Error in submitting request. Please try again later.", alertActions: [okAction], vc: self)
                }
            }
            
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func editRecipeAction(_ sender: Any) {
        self.performSegue(withIdentifier: "detailToEdit", sender: nil)
    }
}

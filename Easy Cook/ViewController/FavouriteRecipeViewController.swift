//
//  FavouriteRecipeViewController.swift
//  Easy Cook
//
//  Created by Kua Jun Hong on 1/12/2020.
//

import UIKit

class FavouriteRecipeViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var favouriteRecipeTitleLabel: UILabel!
    @IBOutlet weak var favouriteRecipeTableView: UITableView!
    @IBOutlet weak var emptyRecipeLabel: UILabel!
    
    // MARK: Constraint Layout
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    // MARK: - Variable declaration
    
    private var recipeList: [RecipeDetail] = []
    private var selectedRecipe = RecipeDetail()
    
    // MARK: - Override func

    override func viewDidLoad() {
        super.viewDidLoad()

        favouriteRecipeTableView.delegate = self
        favouriteRecipeTableView.dataSource = self
        favouriteRecipeTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        getFavouriteRecipe()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let tableView = object as? UITableView, tableView == favouriteRecipeTableView, keyPath! == "contentSize" {
            self.tableViewHeight.constant = Util.getTableViewHeightMethod(tableView: self.favouriteRecipeTableView) + 20.0
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "favorToRecipeDetails" {
            if let vc = segue.destination as? RecipeDetailsViewController {
                vc.recipeDetail = self.selectedRecipe
                vc.isFavorRecipe = true
            }
        }
    }
    
    // MARK: - Private func
    
    private func getFavouriteRecipe() {
        recipeList = FMDBDatabaseModel.retrieveFavouriteRecipeOnly()
        favouriteRecipeTableView.reloadData()
        emptyRecipeLabel.isHidden = recipeList.count > 0
    }
}

extension FavouriteRecipeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = favouriteRecipeTableView.dequeueReusableCell(withIdentifier: "FavouriteTableViewCell", for: indexPath) as? FavouriteTableViewCell {
            
            cell.recipeTitleLabel.text = recipeList[indexPath.row].name
            if recipeList[indexPath.row].image.contains("https"), let url = URL(string: recipeList[indexPath.row].image) {
                cell.recipeImageView?.sd_setImage(with: url, placeholderImage: nil)
            } else {
                if let data = recipeList[indexPath.row].image.fromBase64() {
                    cell.recipeImageView.image = UIImage(data: data)
                }
            }
            cell.recipeLikeLabel.text = "\(recipeList[indexPath.row].likes) likes"
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRecipe = recipeList[indexPath.row]
        self.performSegue(withIdentifier: "favorToRecipeDetails", sender: nil)
    }
}

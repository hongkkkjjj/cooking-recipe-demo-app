//
//  SearchViewController.swift
//  Easy Cook
//
//  Created by Kua Jun Hong on 03/12/2020.
//

import UIKit

class SearchViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var recipeTableView: UITableView!
    @IBOutlet weak var recipeSearchBar: UISearchBar!
    
    // MARK: - Variable declaration
    
    private var recipeList: [RecipeDetail] = []
    private var searchList: [RecipeDetail] = []
    private var selectedRecipe = RecipeDetail()
    private var isSearching = false
    
    // MARK: - Override func
    
    override func viewDidLoad() {
        self.recipeList = FMDBDatabaseModel.getMaximumRecipe()
        recipeSearchBar.delegate = self
        recipeTableView.delegate = self
        recipeTableView.dataSource = self
        recipeTableView.reloadData()
        
        let hideGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(hideGesture)
        hideGesture.cancelsTouchesInView = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchToRecipeDetails" {
            if let vc = segue.destination as? RecipeDetailsViewController {
                vc.recipeDetail = self.selectedRecipe
            }
        }
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = isSearching ? searchList.count : recipeList.count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeTableViewCell", for: indexPath) as? RecipeTableViewCell {
            
            let dataList = isSearching ? searchList : recipeList
            
            cell.recipeNameLabel.text = dataList[indexPath.row].name
            cell.recipeImageView.sd_setImage(with: URL(string: dataList[indexPath.row].image), placeholderImage: nil)
            cell.recipeCategoryLabel.text = dataList[indexPath.row].category
            cell.recipeLikesLabel.text = "\(dataList[indexPath.row].likes) likes"
            
            cell.recipeContentView.backgroundColor = indexPath.row % 2 == 0 ? UIColor.lightGray : UIColor.white
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRecipe = isSearching ? searchList[indexPath.row] : recipeList[indexPath.row]
        self.performSegue(withIdentifier: "searchToRecipeDetails", sender: nil)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let nameList = recipeList.filter({String(($0.name.prefix(searchText.count))).uppercased() == searchText.uppercased()})
        let categoryList = recipeList.filter({String(($0.category.prefix(searchText.count))).uppercased() == searchText.uppercased()})
        searchList = nameList
        for category in categoryList {
            if !searchList.contains(where: {(selfRecipe) -> Bool in
                return selfRecipe.category == category.category
            }) {
                searchList.append(category)
            }
        }
        isSearching = true
        recipeTableView.reloadData()
    }
}

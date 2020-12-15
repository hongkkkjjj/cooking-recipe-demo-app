//
//  SearchViewController.swift
//  Easy Cook
//
//  Created by Kua Jun Hong on 03/12/2020.
//

import UIKit
import AEXML

class SearchViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var recipeTableView: UITableView!
    @IBOutlet weak var categoryFilterButton: UIButton!
    
    // MARK: - Variable declaration
    
    private var recipeList: [RecipeDetail] = []
    private var searchList: [RecipeDetail] = []
    private var selectedRecipe = RecipeDetail()
    private var isSearching = false
    
    private var xmlText = ""
    private var recipe = RecipeDetail()
    private var recipeXML = AEXMLDocument()
    internal var filterCategory = ""
        
    // MARK: - Override func
    
    override func viewDidLoad() {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.recipeList = FMDBDatabaseModel.getMaximumRecipe()
        
        let recipeLst = FMDBDatabaseModel.getMaximumRecipe()
        recipeXML = AEXMLDocument()
        let recipeHeader = recipeXML.addChild(name: "recipelist")
        for eachRecipe in recipeLst {
            let recipe = recipeHeader.addChild(name: "recipe")
            recipe.addChild(name: "id", value: String(eachRecipe.id))
            recipe.addChild(name: "name", value: eachRecipe.name)
            recipe.addChild(name: "image", value: eachRecipe.image)
            recipe.addChild(name: "likes", value: String(eachRecipe.likes))
            recipe.addChild(name: "view", value: String(eachRecipe.view))
            recipe.addChild(name: "category", value: eachRecipe.category)
            
            let ingredientsHeader = recipe.addChild(name: "ingredients")
            for ingredient in eachRecipe.ingredients {
                ingredientsHeader.addChild(name: "ingredient", value: ingredient)
            }
            
            let stepsHeader = recipe.addChild(name: "steps")
            for step in eachRecipe.steps {
                stepsHeader.addChild(name: "step", value: step)
            }
        }
        
        recipeTableView.delegate = self
        recipeTableView.dataSource = self
        recipeTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchToRecipeDetails" {
            if let vc = segue.destination as? RecipeDetailsViewController {
                vc.recipeDetail = self.selectedRecipe
            }
        } else if segue.identifier == "searchToAdd" {
            if let vc = segue.destination as? RecipeEditViewController {
                vc.editOrAdd = 1
            }
        }
    }
    
    // MARK: - Private func
    
    private func filterData() {
        if filterCategory != "" {
            if parseXML() != nil {
                recipeTableView.reloadData()
            }
        } else {
            recipeTableView.reloadData()
        }
    }
    
    private func parseXML() -> [RecipeDetail]? {
        if let data = recipeXML.xml.data(using: .utf8) {
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
            return searchList
        }
        return nil
    }
    
    // MARK: - IBAction
    
    @IBAction func filterButtonAction(_ sender: Any) {
        if filterCategory.isEmpty {
            if let vc = UIStoryboard(name: "PopUpStoryboard", bundle: nil).instantiateViewController(withIdentifier: "CategoryPickerViewController") as? CategoryPickerViewController {
                
                vc.delegate = self
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
            }
        } else {
            filterCategory = ""
            categoryFilterButton.setTitle("Category Filter", for: .normal)
            isSearching = false
            filterData()
        }
    }
    
    
    @IBAction func addRecipeButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "searchToAdd", sender: nil)
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
            if dataList[indexPath.row].image.contains("https"), let url = URL(string: dataList[indexPath.row].image) {
                cell.recipeImageView.sd_setImage(with: url, placeholderImage: nil)
            } else {
                if let data = dataList[indexPath.row].image.fromBase64() {
                    cell.recipeImageView.image = UIImage(data: data)
                }
            }
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

// MARK: - XMLParserDelegate

extension SearchViewController: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        xmlText = ""
        if elementName == "recipelist" {
            searchList.removeAll()
        } else if elementName == "recipe" {
            recipe = RecipeDetail()
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "name" {
            recipe.name = xmlText
        } else if elementName == "image" {
            recipe.image = xmlText
        } else if elementName == "category" {
            recipe.category = xmlText
        } else if elementName == "likes" {
            if let intLike = Int(xmlText) {
                recipe.likes = intLike
            }
        } else if elementName == "id" {
            if let intId = Int(xmlText) {
                recipe.id = intId
            }
        } else if elementName == "view" {
            if let intView = Int(xmlText) {
                recipe.view = intView
            }
        } else if elementName == "ingredient" {
            recipe.ingredients.append(xmlText)
        } else if elementName == "step" {
            recipe.steps.append(xmlText)
        } else if elementName == "recipe" {
            if recipe.category == filterCategory {
                searchList.append(recipe)
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        xmlText += string
    }
}

// MARK: - CategoryPickerVCDelegate

extension SearchViewController: CategoryPickerVCDelegate {
    func getCategoryFromPicker(str: String) {
        self.filterCategory = str
        categoryFilterButton.setTitle(str, for: .normal)
        isSearching = true
        filterData()
    }
}

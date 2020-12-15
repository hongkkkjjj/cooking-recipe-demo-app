//
//  ActivationViewController.swift
//  Easy Cook
//
//  Created by Kua Jun Hong on 02/12/2020.
//

import UIKit

class ActivationViewController: UIViewController {
    
    // MARK: - Variable Declaration
    
    private var xmlText = ""
    private var recipeList = [RecipeDetail()]
    private var recipe = RecipeDetail()
    
    // MARK: - Override func

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if FMDBDatabaseModel.checkRowCount() {
            goMain()
        } else {
            let extractData = getDataFromXML()
            let result = FMDBDatabaseModel.insertData(recipeList: extractData)
            print("Insert recipe data success: \(result)")
            if result {
                goMain()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        LoadingScreen.shared.showOverlay(view: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        LoadingScreen.shared.hideOverlayView(view: self)
    }
    
    
    private func getDataFromXML() -> [RecipeDetail] {
        print("setup dummy data here")
        
        if let path = Bundle.main.url(forResource: "recipeList", withExtension: "xml") {
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                parser.parse()
                return recipeList
            }
        }
        
        return [RecipeDetail()]
    }

    private func goMain() {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            self.performSegue(withIdentifier: "FromActivationToTabNav", sender: nil)
        })
    }
}

extension ActivationViewController: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        xmlText = ""
        if elementName == "recipeList" {
            recipeList.removeAll()
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
        } else if elementName == "view" {
            if let intView = Int(xmlText) {
                recipe.view = intView
            }
        } else if elementName == "ingredient" {
            recipe.ingredients.append(xmlText)
        } else if elementName == "step" {
            recipe.steps.append(xmlText)
        } else if elementName == "recipe" {
            recipeList.append(recipe)
        }
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        xmlText += string
    }
}

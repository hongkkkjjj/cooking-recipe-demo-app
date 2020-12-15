//
//  HomeViewController.swift
//  Easy Cook
//
//  Created by Kua Jun Hong on 27/11/2020.
//

import UIKit
import SDWebImage

class HomeViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var popularTitleLabel: UILabel!
    @IBOutlet weak var popularCollectionView: UICollectionView!
    @IBOutlet weak var favouriteTitleLabel: UILabel!
    @IBOutlet weak var favouriteCollectionView: UICollectionView!
    @IBOutlet weak var emptyFavouriteView: UILabel!
    
    // MARK: - Variable Declaration
    
    private var popularRecipeList: [RecipeDetail] = []
    private var favouriteRecipeList: [RecipeDetail] = []
    private var favouriteRecipe: Bool = false
    private var selectedRecipe = RecipeDetail()
    
    // MARK: - Override func

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        popularCollectionView.delegate = self
        popularCollectionView.dataSource = self
        favouriteCollectionView.delegate = self
        favouriteCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        loadRecipe()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mainToRecipeDetails" {
            if let vc = segue.destination as? RecipeDetailsViewController {
                vc.recipeDetail = self.selectedRecipe
                vc.isFavorRecipe = self.favouriteRecipe
            }
        }
    }

    // MARK: - Private func
    
    private func loadRecipe() {
        let dbResult = FMDBDatabaseModel.retrievePopularAndFavouriteRecipe()
        popularRecipeList.removeAll()
        favouriteRecipeList.removeAll()
        if dbResult.count > 5 {
            for pi in 0 ... 4 {
                popularRecipeList.append(dbResult[pi])
            }
            for fi in 5 ... dbResult.count - 1 {
                favouriteRecipeList.append(dbResult[fi])
            }
            favouriteCollectionView.isHidden = false
            emptyFavouriteView.isHidden = true
        } else {
            popularRecipeList = dbResult
            favouriteCollectionView.isHidden = true
            emptyFavouriteView.isHidden = false
        }
        popularCollectionView.reloadData()
        favouriteCollectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == popularCollectionView {
            return popularRecipeList.count
        } else if collectionView == favouriteCollectionView {
            return favouriteRecipeList.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == popularCollectionView {
            if let popularCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularCollectionViewCell", for: indexPath) as? PopularCollectionViewCell {
            
                let row = indexPath.row
                popularCell.recipeTitleLabel.text = popularRecipeList[row].name
                if popularRecipeList[row].image.contains("https:"), let url = URL(string: popularRecipeList[row].image) {
                    popularCell.recipeImageView.sd_setImage(with: url, placeholderImage: nil)
                } else {
                    if let data = popularRecipeList[row].image.fromBase64() {
                        popularCell.recipeImageView.image = UIImage(data: data)
                    }
                }
            
                return popularCell
            }
        } else if collectionView == favouriteCollectionView {
            if let favouriteCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavouriteCollectionViewCell", for: indexPath) as? FavouriteCollectionViewCell {
            
                let row = indexPath.row
                favouriteCell.recipeTitleLabel.text = favouriteRecipeList[row].name
                if favouriteRecipeList[row].image.contains("https:"), let url = URL(string: favouriteRecipeList[row].image) {
                    favouriteCell.recipeImageView.sd_setImage(with: url, placeholderImage: nil)
                } else {
                    if let data = favouriteRecipeList[row].image.fromBase64() {
                        favouriteCell.recipeImageView.image = UIImage(data: data)
                    }
                }
            
                return favouriteCell
            }
        }
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == popularCollectionView {
            favouriteRecipe = false
            
            self.selectedRecipe = popularRecipeList[indexPath.row]
            self.performSegue(withIdentifier: "mainToRecipeDetails", sender: nil)
            
        } else if collectionView == favouriteCollectionView {
            favouriteRecipe = true
            
            self.selectedRecipe = favouriteRecipeList[indexPath.row]
            self.performSegue(withIdentifier: "mainToRecipeDetails", sender: nil)
        }
    }
}

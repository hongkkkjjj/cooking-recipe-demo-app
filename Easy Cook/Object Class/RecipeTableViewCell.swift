//
//  RecipeTableViewCell.swift
//  Easy Cook
//
//  Created by Kua Jun Hong on 03/12/2020.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var recipeContentView: UIView!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var recipeLikesLabel: UILabel!
    @IBOutlet weak var recipeCategoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        recipeImageView.layer.cornerRadius = 8
        recipeContentView.layer.cornerRadius = 8
    }
    
}


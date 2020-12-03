//
//  FavouriteTableViewCell.swift
//  Easy Cook
//
//  Created by Kua Jun Hong on 1/12/2020.
//

import UIKit

class FavouriteTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var favouriteRecipeContentView: UIView!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeTitleLabel: UILabel!
    @IBOutlet weak var recipeLikeLabel: UILabel!
    
    // MARK: - Override func
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        recipeImageView.layer.cornerRadius = 8
        favouriteRecipeContentView.layer.cornerRadius = 8
        favouriteRecipeContentView.layer.borderWidth = 2
        favouriteRecipeContentView.layer.borderColor = UIColor.black.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

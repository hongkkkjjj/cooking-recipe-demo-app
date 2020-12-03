//
//  FavouriteCollectionViewCell.swift
//  Easy Cook
//
//  Created by Kua Jun Hong on 1/12/2020.
//

import UIKit

class FavouriteCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlet
    @IBOutlet weak var recipeContentView: UIView!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeTitleView: UIView!
    @IBOutlet weak var recipeTitleLabel: UILabel!
    
    // MARK: - Override
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        recipeContentView.layer.cornerRadius = 12
    }
}

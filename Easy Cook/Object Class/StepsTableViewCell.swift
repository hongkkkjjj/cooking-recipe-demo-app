//
//  StepsTableViewCell.swift
//  Easy Cook
//
//  Created by Kua Jun Hong on 10/12/2020.
//

import UIKit

class StepsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var stepContentView: UIView!
    @IBOutlet weak var stepTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        stepTextView.layer.cornerRadius = 8
        stepTextView.layer.borderWidth = 1
    }
}

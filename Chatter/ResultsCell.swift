//
//  ResultsCell.swift
//  Chatter
//
//  Created by Cliff Choiniere on 2/22/17.
//  Copyright © 2017 Cliff Choiniere. All rights reserved.
//

import UIKit

class ResultsCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let theWidth = UIScreen.main.bounds.width
        
        contentView.frame = CGRect(x: 0, y: 0, width: theWidth, height: 120)
        
        profileImage.center = CGPoint(x: 60, y: 60)
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        profileNameLabel.center = CGPoint(x: 230, y: 55)
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

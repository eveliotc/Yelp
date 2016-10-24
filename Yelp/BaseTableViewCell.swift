//
//  BaseTableViewCell.swift
//  Yelp
//
//  Created by Evelio Tarazona on 10/23/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        let action = {
            self.contentView.backgroundColor = selected ? Colors.main : nil
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: action)
        } else {
            action()
        }
        
    }

}

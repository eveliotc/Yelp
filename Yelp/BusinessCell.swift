//
//  BusinessCell.swift
//  Yelp
//
//  Created by Evelio Tarazona on 10/22/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessCell: BaseTableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var reviewsLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var business : Business! {
        didSet {
            
            if let url = business.imageURL {
                photoImageView.setImageWith(url, placeholderImage: Placeholders.image)
            } else {
                photoImageView.image = Placeholders.image
            }
            if let url = business.ratingImageURL {
                ratingImageView.setImageWith(url, placeholderImage: Placeholders.image)
            } else {
                ratingImageView.image = Placeholders.image
            }
            
            nameLabel.text = business.name ?? ""
            addressLabel.text = business.address ?? ""
            categoriesLabel.text = business.categories ?? ""
            reviewsLabel.text = "\(business.reviewCount!) Reviews"
            distanceLabel.text = business.distance ?? ""
            
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        photoImageView.layer.cornerRadius = 5
        photoImageView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        photoImageView.cancelImageRequestOperation()
        ratingImageView.cancelImageRequestOperation()
    }

}

//
//  BusinessViewController.swift
//  Yelp
//
//  Created by Evelio Tarazona on 10/23/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessViewController: UITableViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var reviewsLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    var business : Business!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        navigationController?.navigationBar.topItem?.backBarButtonItem?.tintColor = UIColor.white
        navigationController?.navigationBar.topItem?.title = "Search"

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

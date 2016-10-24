//
//  Filters.swift
//  Yelp
//
//  Created by Evelio Tarazona on 10/22/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import Foundation


struct Filters {
    let categories: [String]
    let radius: Int
    let sort: YelpSortMode
    let deals: Bool
    
    init(categories: [String], radius: Int, sort: YelpSortMode, deals: Bool) {
        self.categories = categories
        self.radius = radius
        self.sort = sort
        self.deals = deals
    }
}

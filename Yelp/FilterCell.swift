
//
//  FilterCell.swift
//  Yelp
//
//  Created by Evelio Tarazona on 10/22/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FilterCellDelegate {
    @objc optional func filterCell(filterCell: FilterCell, didChangeValue value: Bool)
}

class FilterCell: BaseTableViewCell {

    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var filterSwitch: SevenSwitch!
    weak var delegate: FilterCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        filterSwitch.addTarget(self, action: #selector(FilterCell.switchValueChanged), for: UIControlEvents.valueChanged)
    }
    
    func switchValueChanged() {
        delegate?.filterCell?(filterCell: self, didChangeValue: filterSwitch.isOn())
    }
    
    func setOn(_ on: Bool) {
        filterSwitch.setOn(on, animated: true)
        switchValueChanged()
    }

}

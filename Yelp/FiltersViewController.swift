//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Evelio Tarazona on 10/22/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit


protocol FiltersViewControllerDelegate: class {
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: Filters?)
}

class FiltersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    weak var delegate: FiltersViewControllerDelegate?
    
    var sections = [
        Section(title: "Deals", items: Section.buildDealOptions()),
        Section(title: "Distance", items: Section.buildDistanceOptions(), selectionMode: .single),
        Section(title: "Sort by", items: Section.buildSortOptions(), selectionMode: .single),
        Section(title: "Category", items: Section.buildCategories(), collapsed: true, maxCollapsedItems: 3)
    ]
    
    @IBAction func onSearchTapped(_ sender: UIBarButtonItem) {
        let dealsSectionIndex = 0;
        let distanceSectionIndex = 1;
        let sortSectionIndex = 2;
        let categorySectionIndex = 3;
        
        let radius = sections[distanceSectionIndex].items[sections[distanceSectionIndex].selectedIndex]["radius"] as! Int
        let sort = sections[sortSectionIndex].items[sections[sortSectionIndex].selectedIndex]["sort"]  as! YelpSortMode
        let deals = (sections[dealsSectionIndex].switchStates[0] ?? false)!
        
        var selectedCategories = [String]()
        for (row, selected) in sections[categorySectionIndex].switchStates {
            if (selected!) {
                selectedCategories.append(sections[categorySectionIndex].items[row]["code"] as! String)
            }
        }
        
        let filters = Filters(categories: selectedCategories, radius: radius, sort: sort, deals: deals)
        delegate?.filtersViewController(filtersViewController: self, didUpdateFilters: filters)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCancelTapped(_ sender: UIBarButtonItem) {
        delegate?.filtersViewController(filtersViewController: self, didUpdateFilters: nil)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
    }
}

extension FiltersViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].itemCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let collapsed = sections[indexPath.section].collapsed
        if collapsed && sections[indexPath.section].selectionMode == .single {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CollapsedCell", for: indexPath) as! CollapsedCell
            cell.collapsedLabel.text = sections[indexPath.section].selectedName()
            return cell
        }
        
        if collapsed && indexPath.row >= sections[indexPath.section].maxCollapsedItems {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CollapsedCell", for: indexPath) as! CollapsedCell
            cell.collapsedLabel.text = "See all"
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as! FilterCell
        cell.filterLabel.text = sections[indexPath.section].items[indexPath.row]["name"] as? String
        cell.filterSwitch.setOn((sections[indexPath.section].switchStates[indexPath.row] ?? false)!, animated: false)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        let wasCollapsed = sections[indexPath.section].collapsed
        if cell is FilterCell {
            let filterCell = cell as! FilterCell
            
            if sections[indexPath.section].selectionMode == .single {
                filterCell.setOn(true)
                sections[indexPath.section].collapsed = true
            } else {
                filterCell.setOn(!filterCell.filterSwitch.isOn())
            }
        }
        if cell is CollapsedCell {
            sections[indexPath.section].collapsed = false
        }
        
        if wasCollapsed != sections[indexPath.section].collapsed {
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: UITableViewRowAnimation.automatic)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}

extension FiltersViewController: FilterCellDelegate {
    
    func filterCell(filterCell: FilterCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: filterCell)!
        
        let oldIndex = sections[indexPath.section].selectedIndex
        sections[indexPath.section].onItemChanged(index: indexPath.row, selected: value)
        if sections[indexPath.section].selectionMode == .single {
            if oldIndex != sections[indexPath.section].selectedIndex {
                ensureViewState(index: oldIndex, section: indexPath.section, on: false)
            }
            ensureViewState(index: sections[indexPath.section].selectedIndex, section: indexPath.section, on: true)
            
            sections[indexPath.section].collapsed = true
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: UITableViewRowAnimation.automatic)
        }
    }
    
    func ensureViewState(index: Int, section: Int, on: Bool) {
        let indexPath = IndexPath(row: index, section: section)
        let cell = tableView.cellForRow(at: indexPath) as! FilterCell
        cell.filterSwitch.setOn(on, animated: true)
    }
}

enum SelectionMode {
    case single, multiple
}

struct Section {
    let title: String
    let items: [[String:Any]]
    let selectionMode: SelectionMode
    var selectedIndex: Int = 0
    var switchStates: [Int:Bool?] = [:]
    var collapsed: Bool
    let maxCollapsedItems: Int
    
    init(title: String, items: [[String:Any]] = [], collapsed: Bool = false, maxCollapsedItems: Int = 1, selectionMode: SelectionMode = .multiple) {
        self.title = title
        self.items = items
        self.collapsed = collapsed || selectionMode == .single
        self.maxCollapsedItems = maxCollapsedItems
        self.selectionMode = selectionMode
        onItemChanged(index: selectedIndex, selected: selectionMode == .single)
    }
    
    mutating func onItemChanged(index: Int, selected: Bool) {
        let oldIndex = selectedIndex
        selectedIndex = index
        switchStates[index] = selected
        if selectionMode == .single {
            if oldIndex != selectedIndex {
                switchStates[oldIndex] = false
            }
            if !selected {
                selectedIndex = 0
                switchStates[0] = true
            }
        }
        
    }
    
    func itemCount() -> Int {
        if collapsed {
            return selectionMode == .single ? 1
                : maxCollapsedItems + 1
        }
        return items.count
    }
    
    func selectedName() -> String? {
        return items[selectedIndex]["name"] as? String
    }
    
    static func buildDealOptions() -> [[String:String]] {
        return [["name" : "Offering a Deal"]]
    }
    
    static func buildDistanceOptions() -> [[String:Any]] {
        return [
            ["name" : "Auto", "radius": 0],
            ["name" : "0.5 miles", "radius": 1000],
            ["name" : "1 mile", "radius": 2000],
            ["name" : "6 miles", "radius": 10000],
            ["name" : "25 miles", "radius": 40000]
        ]
    }
    
    static func buildSortOptions() -> [[String:Any]] {
        return [
            ["name" : "Best match", "sort": YelpSortMode.bestMatched],
            ["name" : "Distance", "sort": YelpSortMode.distance],
            ["name" : "Highest rated", "sort": YelpSortMode.highestRated],
        ]
    }
    
    static func buildCategories() -> [[String:String]] {
        return [["name" : "Afghan", "code": "afghani"],
                ["name" : "African", "code": "african"],
                ["name" : "American, New", "code": "newamerican"],
                ["name" : "American, Traditional", "code": "tradamerican"],
                ["name" : "Arabian", "code": "arabian"],
                ["name" : "Argentine", "code": "argentine"],
                ["name" : "Armenian", "code": "armenian"],
                ["name" : "Asian Fusion", "code": "asianfusion"],
                ["name" : "Asturian", "code": "asturian"],
                ["name" : "Australian", "code": "australian"],
                ["name" : "Austrian", "code": "austrian"],
                ["name" : "Baguettes", "code": "baguettes"],
                ["name" : "Bangladeshi", "code": "bangladeshi"],
                ["name" : "Barbeque", "code": "bbq"],
                ["name" : "Basque", "code": "basque"],
                ["name" : "Bavarian", "code": "bavarian"],
                ["name" : "Beer Garden", "code": "beergarden"],
                ["name" : "Beer Hall", "code": "beerhall"],
                ["name" : "Beisl", "code": "beisl"],
                ["name" : "Belgian", "code": "belgian"],
                ["name" : "Bistros", "code": "bistros"],
                ["name" : "Black Sea", "code": "blacksea"],
                ["name" : "Brasseries", "code": "brasseries"],
                ["name" : "Brazilian", "code": "brazilian"],
                ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
                ["name" : "British", "code": "british"],
                ["name" : "Buffets", "code": "buffets"],
                ["name" : "Bulgarian", "code": "bulgarian"],
                ["name" : "Burgers", "code": "burgers"],
                ["name" : "Burmese", "code": "burmese"],
                ["name" : "Cafes", "code": "cafes"],
                ["name" : "Cafeteria", "code": "cafeteria"],
                ["name" : "Cajun/Creole", "code": "cajun"],
                ["name" : "Cambodian", "code": "cambodian"],
                ["name" : "Canadian", "code": "New)"],
                ["name" : "Canteen", "code": "canteen"],
                ["name" : "Caribbean", "code": "caribbean"],
                ["name" : "Catalan", "code": "catalan"],
                ["name" : "Chech", "code": "chech"],
                ["name" : "Cheesesteaks", "code": "cheesesteaks"],
                ["name" : "Chicken Shop", "code": "chickenshop"],
                ["name" : "Chicken Wings", "code": "chicken_wings"],
                ["name" : "Chilean", "code": "chilean"],
                ["name" : "Chinese", "code": "chinese"],
                ["name" : "Comfort Food", "code": "comfortfood"],
                ["name" : "Corsican", "code": "corsican"],
                ["name" : "Creperies", "code": "creperies"],
                ["name" : "Cuban", "code": "cuban"],
                ["name" : "Curry Sausage", "code": "currysausage"],
                ["name" : "Cypriot", "code": "cypriot"],
                ["name" : "Czech", "code": "czech"],
                ["name" : "Czech/Slovakian", "code": "czechslovakian"],
                ["name" : "Danish", "code": "danish"],
                ["name" : "Delis", "code": "delis"],
                ["name" : "Diners", "code": "diners"],
                ["name" : "Dumplings", "code": "dumplings"],
                ["name" : "Eastern European", "code": "eastern_european"],
                ["name" : "Ethiopian", "code": "ethiopian"],
                ["name" : "Fast Food", "code": "hotdogs"],
                ["name" : "Filipino", "code": "filipino"],
                ["name" : "Fish & Chips", "code": "fishnchips"],
                ["name" : "Fondue", "code": "fondue"],
                ["name" : "Food Court", "code": "food_court"],
                ["name" : "Food Stands", "code": "foodstands"],
                ["name" : "French", "code": "french"],
                ["name" : "French Southwest", "code": "sud_ouest"],
                ["name" : "Galician", "code": "galician"],
                ["name" : "Gastropubs", "code": "gastropubs"],
                ["name" : "Georgian", "code": "georgian"],
                ["name" : "German", "code": "german"],
                ["name" : "Giblets", "code": "giblets"],
                ["name" : "Gluten-Free", "code": "gluten_free"],
                ["name" : "Greek", "code": "greek"],
                ["name" : "Halal", "code": "halal"],
                ["name" : "Hawaiian", "code": "hawaiian"],
                ["name" : "Heuriger", "code": "heuriger"],
                ["name" : "Himalayan/Nepalese", "code": "himalayan"],
                ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
                ["name" : "Hot Dogs", "code": "hotdog"],
                ["name" : "Hot Pot", "code": "hotpot"],
                ["name" : "Hungarian", "code": "hungarian"],
                ["name" : "Iberian", "code": "iberian"],
                ["name" : "Indian", "code": "indpak"],
                ["name" : "Indonesian", "code": "indonesian"],
                ["name" : "International", "code": "international"],
                ["name" : "Irish", "code": "irish"],
                ["name" : "Island Pub", "code": "island_pub"],
                ["name" : "Israeli", "code": "israeli"],
                ["name" : "Italian", "code": "italian"],
                ["name" : "Japanese", "code": "japanese"],
                ["name" : "Jewish", "code": "jewish"],
                ["name" : "Kebab", "code": "kebab"],
                ["name" : "Korean", "code": "korean"],
                ["name" : "Kosher", "code": "kosher"],
                ["name" : "Kurdish", "code": "kurdish"],
                ["name" : "Laos", "code": "laos"],
                ["name" : "Laotian", "code": "laotian"],
                ["name" : "Latin American", "code": "latin"],
                ["name" : "Live/Raw Food", "code": "raw_food"],
                ["name" : "Lyonnais", "code": "lyonnais"],
                ["name" : "Malaysian", "code": "malaysian"],
                ["name" : "Meatballs", "code": "meatballs"],
                ["name" : "Mediterranean", "code": "mediterranean"],
                ["name" : "Mexican", "code": "mexican"],
                ["name" : "Middle Eastern", "code": "mideastern"],
                ["name" : "Milk Bars", "code": "milkbars"],
                ["name" : "Modern Australian", "code": "modern_australian"],
                ["name" : "Modern European", "code": "modern_european"],
                ["name" : "Mongolian", "code": "mongolian"],
                ["name" : "Moroccan", "code": "moroccan"],
                ["name" : "New Zealand", "code": "newzealand"],
                ["name" : "Night Food", "code": "nightfood"],
                ["name" : "Norcinerie", "code": "norcinerie"],
                ["name" : "Open Sandwiches", "code": "opensandwiches"],
                ["name" : "Oriental", "code": "oriental"],
                ["name" : "Pakistani", "code": "pakistani"],
                ["name" : "Parent Cafes", "code": "eltern_cafes"],
                ["name" : "Parma", "code": "parma"],
                ["name" : "Persian/Iranian", "code": "persian"],
                ["name" : "Peruvian", "code": "peruvian"],
                ["name" : "Pita", "code": "pita"],
                ["name" : "Pizza", "code": "pizza"],
                ["name" : "Polish", "code": "polish"],
                ["name" : "Portuguese", "code": "portuguese"],
                ["name" : "Potatoes", "code": "potatoes"],
                ["name" : "Poutineries", "code": "poutineries"],
                ["name" : "Pub Food", "code": "pubfood"],
                ["name" : "Rice", "code": "riceshop"],
                ["name" : "Romanian", "code": "romanian"],
                ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
                ["name" : "Rumanian", "code": "rumanian"],
                ["name" : "Russian", "code": "russian"],
                ["name" : "Salad", "code": "salad"],
                ["name" : "Sandwiches", "code": "sandwiches"],
                ["name" : "Scandinavian", "code": "scandinavian"],
                ["name" : "Scottish", "code": "scottish"],
                ["name" : "Seafood", "code": "seafood"],
                ["name" : "Serbo Croatian", "code": "serbocroatian"],
                ["name" : "Signature Cuisine", "code": "signature_cuisine"],
                ["name" : "Singaporean", "code": "singaporean"],
                ["name" : "Slovakian", "code": "slovakian"],
                ["name" : "Soul Food", "code": "soulfood"],
                ["name" : "Soup", "code": "soup"],
                ["name" : "Southern", "code": "southern"],
                ["name" : "Spanish", "code": "spanish"],
                ["name" : "Steakhouses", "code": "steak"],
                ["name" : "Sushi Bars", "code": "sushi"],
                ["name" : "Swabian", "code": "swabian"],
                ["name" : "Swedish", "code": "swedish"],
                ["name" : "Swiss Food", "code": "swissfood"],
                ["name" : "Tabernas", "code": "tabernas"],
                ["name" : "Taiwanese", "code": "taiwanese"],
                ["name" : "Tapas Bars", "code": "tapas"],
                ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
                ["name" : "Tex-Mex", "code": "tex-mex"],
                ["name" : "Thai", "code": "thai"],
                ["name" : "Traditional Norwegian", "code": "norwegian"],
                ["name" : "Traditional Swedish", "code": "traditional_swedish"],
                ["name" : "Trattorie", "code": "trattorie"],
                ["name" : "Turkish", "code": "turkish"],
                ["name" : "Ukrainian", "code": "ukrainian"],
                ["name" : "Uzbek", "code": "uzbek"],
                ["name" : "Vegan", "code": "vegan"],
                ["name" : "Vegetarian", "code": "vegetarian"],
                ["name" : "Venison", "code": "venison"],
                ["name" : "Vietnamese", "code": "vietnamese"],
                ["name" : "Wok", "code": "wok"],
                ["name" : "Wraps", "code": "wraps"],
                ["name" : "Yugoslav", "code": "yugoslav"]]
    }
}

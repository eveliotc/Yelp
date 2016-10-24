//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MBProgressHUD
import SVPullToRefresh

let kPageSize = 20
class BusinessesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var businesses: [Business]?
    var filters: Filters?
    var offset: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        tableView.addPullToRefresh(actionHandler: { [weak self] in
            self?.loadResults()
        })
        tableView.addInfiniteScrolling(actionHandler: { [weak self] in
            self?.loadResultsStartingAt(self?.businesses?.count ?? 0)
        })
        
        searchBar.delegate = self
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        self.tableView.pullToRefreshView.arrowColor = Colors.main
        self.tableView.pullToRefreshView.textColor = Colors.main
        
        loadResults()
    }
    
    func loadResults() {
        loadResultsStartingAt(0)
    }
    
    func loadResultsStartingAt(_ offset: Int) {
        let term = searchBar.text ?? "Restaurants"
        let sort: YelpSortMode? = filters?.sort
        let deals: Bool? = filters?.deals
        let categories: [String]? = filters?.categories
        let radius: Int? = filters?.radius
        Business.searchWithTerm(
            term: term,
            limit: kPageSize,
            offset: offset,
            sort: sort,
            categories: categories,
            deals: deals,
            radius: radius,
            completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            let append = offset != 0
            if append, let unwrapped = businesses {
                self.businesses?.append(contentsOf: unwrapped)
            } else {
                self.businesses = businesses
            }
            self.tableView.reloadData()
            
            MBProgressHUD.hide(for: self.view, animated: true)
            self.tableView.pullToRefreshView.stopAnimating()
            self.tableView.infiniteScrollingView.stopAnimating()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        searchBar.resignFirstResponder()
        if let detailsController = segue.destination as? BusinessViewController {
            detailsController.business = (sender as! BusinessCell).business
            return
        }
        
        let navController = segue.destination as! UINavigationController
        
        if let filtersControler = navController.topViewController as? FiltersViewController {
            filtersControler.delegate = self
        }
    }
 
}

extension BusinessesViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filters = nil
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(BusinessesViewController.loadResults), object: nil)
        self.perform(#selector(BusinessesViewController.loadResults), with: nil, afterDelay: 0.3)
    }
}

extension BusinessesViewController: FiltersViewControllerDelegate {
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: Filters?) {
        self.filters = filters
        loadResults()
    }
}

extension BusinessesViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        
        cell.business = businesses![indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        searchBar.resignFirstResponder()
    }
    
}

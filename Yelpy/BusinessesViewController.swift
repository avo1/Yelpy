//
//  BusinessesViewController.swift
//  Yelpy
//
//  Created by Dave Vo on 11/17/15.
//  Copyright © 2015 Dave Vo. All rights reserved.
//

import UIKit
import MBProgressHUD

class BusinessesViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var dimmingView: UIView!
  
  var searchBar: UISearchBar!
  var searchTerm = "coffee"
  var businesses = [Business]()
  
  var isLoadingNextPage = false
  var isEndOfFeed = false
  
  var tapGestureOnDimming: UITapGestureRecognizer!
  var loadingView: UIActivityIndicatorView!
  var noMoreResultLabel = UILabel()
  
  // Filters
  let nResults = 20
  var starting = 0
  var categories = [String]()
  var sortBy = 0
  var distance: Int?
  var deals = false
  var filters = [String:AnyObject]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    // Initilize TableView
    tableView.dataSource = self
    tableView.delegate = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 140
    // Add the activity Indicator for table footer for infinity load
    let tableFooterView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 50))
    loadingView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    loadingView.center = tableFooterView.center
    loadingView.hidesWhenStopped = true
    tableFooterView.addSubview(loadingView)
    // Initialize the noMoreResult
    noMoreResultLabel.frame = tableFooterView.frame
    noMoreResultLabel.text = "No more result"
    noMoreResultLabel.textAlignment = NSTextAlignment.Center
    noMoreResultLabel.font = UIFont(name: noMoreResultLabel.font.fontName, size: 15)
    noMoreResultLabel.textColor = UIColor.grayColor()
    noMoreResultLabel.hidden = true
    tableFooterView.addSubview(noMoreResultLabel)
    tableView.tableFooterView = tableFooterView
    
    // Initialize UISearchBar
    searchBar = UISearchBar()
    searchBar.delegate = self
    // Add search bar to navigation bar
    searchBar.sizeToFit()
    navigationItem.titleView = searchBar
    
    // Prepare the dimmingView
    dimmingView.frame.origin.y = 0 //tableView.frame.origin.y
    dimmingView.frame.size.height = tableView.frame.size.height
    dimmingView.backgroundColor = UIColor.grayColor()
    dimmingView.alpha = 0.3
    dimmingView.hidden = true
    tapGestureOnDimming = UITapGestureRecognizer(target: self, action: "cancelSearch:")
    dimmingView.addGestureRecognizer(tapGestureOnDimming)
    
    // Load initial data
    filters["categories"] = categories
    filters["sortBy"] = sortBy
    filters["deal"] = deals
    filters["distanceIdx"] = 0
    filters["distance"] = nil
    
    searchRestaurants(searchTerm, sortBy: sortBy, distance: distance, categories: categories, deals: deals, starting: starting)
  }
  
  func searchRestaurants(term: String!, sortBy: Int!, distance: Int?, categories: [String]?, deals: Bool?, starting: Int?) {
    // Only show HUD if not infinityLoad
    if !isLoadingNextPage {
      MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    }
    
    Business.searchWithTerm(term, sort: YelpSortMode(rawValue: sortBy), distance: distance, categories: categories, deals: deals, starting: starting) { (businesses: [Business]!, error: NSError!) -> Void in
      if businesses != nil {
        print("API returns \(businesses.count)")
        for business in businesses {
          self.businesses.append(business)
          // print(business.name! + " @ " + business.address!)
        }
        self.isEndOfFeed = businesses.count < self.nResults
      } else {
        self.isEndOfFeed = true
      }
      self.noMoreResultLabel.hidden = !self.isEndOfFeed
      self.tableView.reloadData()
      
      MBProgressHUD.hideHUDForView(self.view, animated: true)
      self.isLoadingNextPage = false
    }
  }
  
}

extension BusinessesViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    loadingView.stopAnimating()
    //print(businesses.count)
    return businesses.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("businessCell", forIndexPath: indexPath) as! BusinessCell
    
    cell.business = businesses[indexPath.row]
    cell.nameLabel.text = String(indexPath.row + 1) + ". " + cell.nameLabel.text!
    cell.priceLabel.hidden = !businesses[indexPath.row].hasDeal
    // print("indexpath = \(indexPath.row)")
    
    // Infinite load if last cell
    if !isLoadingNextPage && !isEndOfFeed {
      if indexPath.row == businesses.count - 1 {
        starting += nResults
        loadingView.startAnimating()
        isLoadingNextPage = true
        searchRestaurants(searchTerm, sortBy: sortBy, distance: distance, categories: categories, deals: deals, starting: starting)
      }
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let cell = tableView.cellForRowAtIndexPath(indexPath)!
    cell.contentView.backgroundColor = MyColors.selectedCellColor
  }
  
  func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    let cell = tableView.cellForRowAtIndexPath(indexPath)!
    cell.contentView.backgroundColor = UIColor.whiteColor()
  }
  
}

extension BusinessesViewController: FiltersViewControllerDelegate {
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let navigationController = segue.destinationViewController as! UINavigationController
    let filtersViewController = navigationController.topViewController as! FiltersViewController
    filtersViewController.delegate = self
    filtersViewController.filters = self.filters
  }
  
  func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
    // Clear the list
    starting = 0
    businesses = [Business]()
    
    self.filters = filters
    categories = (filters["categories"] as? [String])!
    sortBy = (filters["sortBy"] as? Int)!
    deals = (filters["deal"] as? Bool)!
    distance = filters["distance"] as? Int
    searchRestaurants(searchTerm, sortBy: sortBy, distance: distance, categories: categories, deals: deals, starting: starting)
  }
  
}

// MARK: - Search bar
extension BusinessesViewController: UISearchBarDelegate {
  func cancelSearch(gesture: UITapGestureRecognizer) {
    if gesture.state == UIGestureRecognizerState.Ended {
      searchBarCancelButtonClicked(searchBar)
    }
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.view.superview?.superview?.endEditing(true)
    searchBar.resignFirstResponder()
  }
  
  func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
    dimmingView.hidden = false
    searchBar.showsCancelButton = true
  }
  
  func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    searchBar.text = ""
    dimmingView.hidden = true
    searchBar.resignFirstResponder()
    searchBar.showsCancelButton = false
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    dimmingView.hidden = true
    searchTerm = searchBar.text!
    searchBar.resignFirstResponder()
    searchBar.showsCancelButton = false
    // Clear the list
    starting = 0
    businesses = [Business]()
    searchRestaurants(searchTerm, sortBy: sortBy, distance: distance, categories: categories, deals: deals, starting: starting)
  }
  
}
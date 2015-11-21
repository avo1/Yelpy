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
  var searchTerm = "Restaurant"
  var businesses = [Business]()
  var foundBiz = [Business]()
  
  var isSearching = false
  var isLoadingNextPage = false
  var isEndOfFeed = false
  
  var tapGestureOnDimming: UITapGestureRecognizer!
  var loadingView: UIActivityIndicatorView!
  var noMoreResultLabel = UILabel()
  
  // Filters
  let nResults = 20
  var starting = 0
  var categories = [String]()
  
  
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
    print(tableView.frame.width)
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
    dimmingView.backgroundColor = MyColors.navigationTintColor
    dimmingView.alpha = 0.1
    dimmingView.hidden = true
    tapGestureOnDimming = UITapGestureRecognizer(target: self, action: "cancelSearch:")
    dimmingView.addGestureRecognizer(tapGestureOnDimming)
    
    // Load initial data
    searchRestaurants(searchTerm, categories: categories, starting: starting)
  }
  
  func searchRestaurants(term: String!, categories: [String]?, starting: Int?) {
    // Only show HUD if not infinityLoad
    if !isLoadingNextPage {
      MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    }
    
    Business.searchWithTerm(term, sort: .Distance, categories: categories, deals: false, starting: starting) { (businesses: [Business]!, error: NSError!) -> Void in
      print(self.businesses.count)
      if businesses != nil {
        for business in businesses {
          self.businesses.append(business)
        }
        self.isEndOfFeed = businesses.count < self.nResults
      } else {
        self.isEndOfFeed = true
      }
      self.noMoreResultLabel.hidden = !self.isEndOfFeed
      self.tableView.reloadData()
      
      MBProgressHUD.hideHUDForView(self.view, animated: true)
      self.isLoadingNextPage = false
      //      for business in businesses {
      //        print(business.name! + " @ " + business.address!)
      //      }
    }
  }
  
}

extension BusinessesViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    loadingView.stopAnimating()
    //print(businesses.count)
      return isSearching ? foundBiz.count : businesses.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("businessCell", forIndexPath: indexPath) as! BusinessCell
    
    cell.business = isSearching ? foundBiz[indexPath.row] : businesses[indexPath.row]
    print("indexpath = \(indexPath.row)")
    
    // Infinite load if last cell
    if !isLoadingNextPage && !isEndOfFeed && !isSearching {
      if indexPath.row == businesses.count - 1 {
        starting += nResults
        loadingView.startAnimating()
        isLoadingNextPage = true
        searchRestaurants(searchTerm, categories: categories, starting: starting)
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
  }
  
  func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
    // Clear the list
    starting = 0
    businesses = [Business]()
    
    categories = (filters["categories"] as? [String])!
    searchRestaurants(searchTerm, categories: categories, starting: starting)
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
    if let st = searchBar.text {
      dimmingView.hidden = !st.isEmpty
    }
    searchBar.enablesReturnKeyAutomatically = true
    searchBar.showsCancelButton = true
  }
  
  func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    searchBar.text = ""
    isSearching = false
    dimmingView.hidden = true
    self.tableView.reloadData()
    searchBar.resignFirstResponder()
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.isEmpty {
      // Load all
      isSearching = false
      self.tableView.reloadData()
      dimmingView.hidden = false
      return
    }
    
    isSearching = true
    dimmingView.hidden = true
    foundBiz = businesses.filter({ (business) -> Bool in
      let biz: Business = business
      let range = NSString(string: biz.name!).rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
      return range.location != NSNotFound
    })
    
    self.tableView.reloadData()
    
  }
  
}
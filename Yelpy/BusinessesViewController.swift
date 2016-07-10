//
//  BusinessesViewController.swift
//  Yelpy
//
//  Created by Dave Vo on 11/17/15.
//  Copyright © 2015 Dave Vo. All rights reserved.
//

import UIKit
import MBProgressHUD
import MapKit

class BusinessesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dimmingView: UIView!
    @IBOutlet weak var navBar: UINavigationItem!
    var mapButton: UIBarButtonItem!
    var cancelSearchButton: UIBarButtonItem!
    
    var searchBar: UISearchBar!
    var searchTerm = "coffee"
    var businesses = [Business]()
    
    var isLoadingNextPage = false
    var isEndOfFeed = false
    
    var tapGestureOnDimming: UITapGestureRecognizer!
    var tapGestureOnMap: UITapGestureRecognizer!
    var loadingView: UIActivityIndicatorView!
    var noMoreResultLabel = UILabel()
    var isMapFullScreen = false
    
    var debounceTimer: NSTimer?
    
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
        searchBar.tintColor = MyColors.bluesky
        searchBar.delegate = self
        // Add search bar to navigation bar
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        
        // Initialize the mapButton
        mapButton = UIBarButtonItem(image: UIImage(named: "Map"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(showMap))
        cancelSearchButton = UIBarButtonItem(image: UIImage(named: "Clear"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(cancelSearch))
        navBar.rightBarButtonItem = mapButton
        
        // Prepare the dimmingView
        dimmingView.frame.origin.y = 0 //tableView.frame.origin.y
        dimmingView.frame.size.height = tableView.frame.size.height
        dimmingView.backgroundColor = UIColor.grayColor()
        dimmingView.alpha = 0.3
        dimmingView.hidden = true
        tapGestureOnDimming = UITapGestureRecognizer(target: self, action: #selector(onTapDimmingView(_:)))
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
    
    func onMapTap(gesture: UITapGestureRecognizer) {
        if isMapFullScreen {
            return
        }
        if gesture.state == UIGestureRecognizerState.Ended {
            showMap()
        }
    }
    
    func showMap() {
        isMapFullScreen = !isMapFullScreen
        navBar.rightBarButtonItem!.image = isMapFullScreen ? UIImage(named: "List") : UIImage(named: "Map")
        // Scroll to top
        //tableView.contentOffset = CGPointMake(0, 0 - tableView.contentInset.top)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        tableView.reloadData()
    }
}

// MARK: - Table View
extension BusinessesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            loadingView.stopAnimating()
            //print(businesses.count)
            return businesses.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("mapCell", forIndexPath: indexPath) as! MapCell
            
            // Remove all annotations
            let annotationsToRemove = cell.mapView.annotations.filter { $0 !== cell.mapView.userLocation }
            cell.mapView.removeAnnotations(annotationsToRemove )
            
            // This is the "current location" used in YelpClient API
            var userLocation = CLLocationCoordinate2D()
            userLocation.latitude = 37.785771
            userLocation.longitude = -122.406165
            
            // Some of math here, 1 degree ~ 111km, ok take 100km for easiness
            // So to have the radius of 3km -> use 0.03 degree
            let span = MKCoordinateSpanMake(0.03, 0.03)
            let region = MKCoordinateRegion(center: userLocation, span: span)
            
            cell.mapView.setRegion(region, animated: true)
            cell.mapView.regionThatFits(region)
            
            for biz in businesses {
                cell.mapView.addAnnotation(biz.location)
            }
            
            tapGestureOnMap = UITapGestureRecognizer(target: self, action: #selector(onMapTap(_:)))
            cell.mapView.addGestureRecognizer(tapGestureOnMap)
            
            return cell
        } else {
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
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return isMapFullScreen ? UIScreen.mainScreen().bounds.size.height : 250
        } else {
            return 80
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            // Expand the map to full screen
            
        } else {
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            cell.contentView.backgroundColor = MyColors.selectedCellColor
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            
        } else {
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            cell.contentView.backgroundColor = UIColor.whiteColor()
        }
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
    func onTapDimmingView(gesture: UITapGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.Ended {
            searchBarCancelButtonClicked(searchBar)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.superview?.superview?.endEditing(true)
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        navBar.rightBarButtonItem = cancelSearchButton
        dimmingView.hidden = false
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        dimmingView.hidden = true
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        navBar.rightBarButtonItem = mapButton
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        dimmingView.hidden = true
        searchTerm = searchBar.text!
        searchBar.resignFirstResponder()
        navBar.rightBarButtonItem = mapButton
        // Clear the list
        starting = 0
        businesses = [Business]()
        searchRestaurants(searchTerm, sortBy: sortBy, distance: distance, categories: categories, deals: deals, starting: starting)
    }
    
    func cancelSearch() {
        searchBar.text = ""
        dimmingView.hidden = true
        searchBar.resignFirstResponder()
        navBar.rightBarButtonItem = mapButton
    }
    
    // Search as you type?
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print("new text = \(searchBar.text!)")
        
        
        searchTerm = searchBar.text!
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
        self.performSelector(#selector(searchNow), withObject: searchTerm, afterDelay: 0.5)
        
        //        // Delay 0.5 seconds
        //        if let timer = debounceTimer {
        //            timer.invalidate()
        //        }
        //        searchTerm = searchBar.text!
        //        debounceTimer = NSTimer(timeInterval: 0.5, target: self, selector: Selector("searchNow"), userInfo: nil, repeats: false)
        //        NSRunLoop.currentRunLoop().addTimer(debounceTimer!, forMode: "NSDefaultRunLoopMode")
    }
    
    func searchNow() {
        print("0.5s later...search now")
        // Clear the list
        self.starting = 0
        self.businesses = [Business]()
        self.searchRestaurants(self.searchTerm, sortBy: self.sortBy, distance: self.distance, categories: self.categories, deals: self.deals, starting: self.starting)
    }
}

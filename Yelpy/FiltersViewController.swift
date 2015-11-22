//
//  FiltersViewController.swift
//  Yelpy
//
//  Created by Dave Vo on 11/19/15.
//  Copyright © 2015 Dave Vo. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
  optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject])
}

class FiltersViewController: UIViewController {
  
  var isDealOfferred = false
  
  var distanceList = ["Auto", "1 km", "3 km", "5 km", "10 km"]
  var distanceListValue = [0, 1000, 3000, 5000, 10000]
  var selectedDistance = 0
  var isExpandingDistanceSection = false
  
  var sortByList = ["Best Matched", "Distance", "Highest Rated"]
  var selectedSortBy = 0
  var isExpandingSortBySection = false
  
  var categories: [[String:String]]!
  var categoriesSwitchStates = [Int:Bool]()
  var isExpandingCategories = false
  var filters = [String:AnyObject]()
  
  weak var delegate: FiltersViewControllerDelegate?
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var resetButton: UIButton!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    categories = Helper.yelpCategories()
    // Load previous selected values
    isDealOfferred = filters["deal"] as! Bool
    selectedDistance = filters["distanceIdx"] as! Int
    selectedSortBy = filters["sortBy"] as! Int
    if let selectedCategoriesIdx = filters["categoriesIdx"] as! [Int]? {
      for id in selectedCategoriesIdx {
        categoriesSwitchStates[id] = true
      }
    }
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.tableFooterView = UIView()
  }
  
  @IBAction func onCancelButton(sender: AnyObject) {
    // If user reset the filters, but the click cancel, then the filters reamins the same as before
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func onSearchButton(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
    var selectedCategories = [String]()
    var selectedCategoriesIdx = [Int]()
    for (row, isSelected) in categoriesSwitchStates {
      if isSelected {
        selectedCategories.append(categories[row]["code"]!)
        selectedCategoriesIdx.append(row)
      }
    }
    filters["categories"] = selectedCategories
    filters["categoriesIdx"] = selectedCategoriesIdx
    
    filters["sortBy"] = selectedSortBy
    filters["deal"] = isDealOfferred
    if selectedDistance == 0 {
      filters["distance"] = nil
    } else {
      filters["distance"] = distanceListValue[selectedDistance]
    }
    filters["distanceIdx"] = selectedDistance
    
    print(filters)
    delegate?.filtersViewController?(self, didUpdateFilters: filters)
  }
  
  @IBAction func onResetClick(sender: UIButton) {
    let alertController = UIAlertController(title: "Yelpy", message: "Are you sure to clear all filters?", preferredStyle: .Alert)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
      
      print(action)
    }
    alertController.addAction(cancelAction)
    
    let destroyAction = UIAlertAction(title: "Clear", style: .Destructive) { (action) in
      self.resetAllFilters()
      print(action)
    }
    alertController.addAction(destroyAction)
    
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  func resetAllFilters() {
    // Reset everything to defaults:
    // No deal, auto distance, sort by distance, all categories unselected
    isDealOfferred = false
    selectedDistance = 0
    isExpandingDistanceSection = false
    selectedSortBy = 0
    isExpandingSortBySection = false
    categoriesSwitchStates = [Int:Bool]()
    tableView.reloadData()
  }
}

// MARK: - Table View
extension FiltersViewController: UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate, CheckBoxCellDelegate {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    switch indexPath.section {
      // Deal
    case 0:
      let cell = tableView.dequeueReusableCellWithIdentifier("checkBoxCell", forIndexPath: indexPath) as! CheckBoxCell
      cell.checkBoxLabel.text = "Offerring a deal"
      cell.checkBox.on = isDealOfferred
      cell.checkBox.userInteractionEnabled = true
      cell.delegate = self
      return cell
      
      // Distance
    case 1:
      let cell = tableView.dequeueReusableCellWithIdentifier("checkBoxCell", forIndexPath: indexPath) as! CheckBoxCell
      cell.checkBoxLabel.text = distanceList[indexPath.row]
      cell.checkBox.on = (indexPath.row == selectedDistance)
      return cell
      
      // Sort by
    case 2:
      let cell = tableView.dequeueReusableCellWithIdentifier("checkBoxCell", forIndexPath: indexPath) as! CheckBoxCell
      cell.checkBoxLabel.text = sortByList[indexPath.row]
      cell.checkBox.on = (indexPath.row == selectedSortBy)
      return cell
      
    case 3:
      let rowLimit = tableView.numberOfRowsInSection(indexPath.section)
      if indexPath.row < rowLimit - 1 {
        let cell = tableView.dequeueReusableCellWithIdentifier("switchCell", forIndexPath: indexPath) as! SwitchCell
        cell.switchLabel.text = categories[indexPath.row]["name"]
        cell.delegate = self
        cell.onSwitch.on = categoriesSwitchStates[indexPath.row] ?? false
        return cell
      } else {
        // This is last row, for the "See more"
        let cell = UITableViewCell()
        let cellText = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 45))
        cellText.text = isExpandingCategories ? "Collapse" : "See more..."
        cellText.textAlignment = .Center
        cell.addSubview(cellText)
        cell.backgroundColor = MyColors.selectedCellColor
        cell.userInteractionEnabled = true
        cell.selectedBackgroundView?.backgroundColor = MyColors.selectedCellColor
        return cell
      }
      
    default:
      return UITableViewCell()
    }
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 4
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0: return 1
    case 1: return distanceList.count
    case 2: return sortByList.count
    case 3: return isExpandingCategories ? categories.count + 1 : 4
    default: return 0
    }
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = UIView()
    var headerTitle = UILabel()
    if section == 0 {
      headerTitle = UILabel(frame: CGRect(x: 15, y: 0, width: 200, height: 35))
    } else {
      headerTitle = UILabel(frame: CGRect(x: 15, y: 15, width: 200, height: 35))
    }
    switch section {
    case 0: headerTitle.text = "Deal"
    case 1: headerTitle.text = "Distance"
    case 2: headerTitle.text = "Sort by"
    case 3: headerTitle.text = "Categories"
    default: headerTitle.text = ""
    }
    headerTitle.textColor = MyColors.carrot
    headerView.addSubview(headerTitle)
    headerView.backgroundColor = MyColors.tableColor
    return headerView
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return section == 0 ? 35 : 50
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    switch indexPath.section {
    case 0, 3: return 44
    case 1: return isExpandingDistanceSection ? 44 : (indexPath.row == selectedDistance ? 44 : 0)
    case 2: return isExpandingSortBySection ? 44 : (indexPath.row == selectedSortBy ? 44 : 0)
    default: return 44
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    switch indexPath.section {
    case 0: break
    case 1:
      // Toggle states for Distance
      if isExpandingDistanceSection {
        selectedDistance = indexPath.row
        isExpandingDistanceSection = false
        tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
      } else {
        // Expand this section
        isExpandingDistanceSection = true
        tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
      }
      
    case 2:
      // Toggle states for SortBy
      if isExpandingSortBySection {
        selectedSortBy = indexPath.row
        isExpandingSortBySection = false
        tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
      } else {
        // Expand this section
        isExpandingSortBySection = true
        tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
      }
      
    case 3:
      isExpandingCategories = !isExpandingCategories
      tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
      
    default: break
    }
  }
  
  func checkBoxCell(checkBoxCell: CheckBoxCell, didChangeValue value: Bool) {
    print("deal = \(value)")
    isDealOfferred = value
  }
  
  func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
    let indexPath = tableView.indexPathForCell(switchCell)!
    // print("filtersVC got the swith event")
    categoriesSwitchStates[indexPath.row] = value
  }
}
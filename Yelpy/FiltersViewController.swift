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
  
  weak var delegate: FiltersViewControllerDelegate?
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    categories = yelpCategories()
    tableView.dataSource = self
    tableView.delegate = self
  }
  
  @IBAction func onCancelButton(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func onSearchButton(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
    
    var filters = [String:AnyObject]()
    var selectedCategories = [String]()
    for (row, isSelected) in categoriesSwitchStates {
      if isSelected {
        selectedCategories.append(categories[row]["code"]!)
      }
    }
    if selectedCategories.count > 0 {
      filters["categories"] = selectedCategories
    } else {
      filters["categories"] =  []
    }
    filters["sortBy"] = selectedSortBy
    filters["deal"] = isDealOfferred
    if selectedDistance == 0 {
      filters["distance"] = nil
    } else {
      filters["distance"] = distanceListValue[selectedDistance]
    }
    
    print(filters)
    delegate?.filtersViewController?(self, didUpdateFilters: filters)
  }
  
  func yelpCategories() -> [[String:String]] {
    let categories = [["name" : "Afghan", "code": "afghani"],
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
    
    return categories
  }
  
}

extension FiltersViewController: UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate, CheckBoxCellDelegate {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    switch indexPath.section {
      // Deal
    case 0:
      let cell = tableView.dequeueReusableCellWithIdentifier("checkBoxCell", forIndexPath: indexPath) as! CheckBoxCell
      cell.checkBoxLabel.text = "Offerring deal"
      cell.checkBox.on = false
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
      let cell = tableView.dequeueReusableCellWithIdentifier("switchCell", forIndexPath: indexPath) as! SwitchCell
      cell.switchLabel.text = categories[indexPath.row]["name"]
      cell.delegate = self
      cell.onSwitch.on = categoriesSwitchStates[indexPath.row] ?? false
      return cell
      
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
    case 3: return categories.count
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
    if indexPath.section == 1 {
      // Toggle states
      if isExpandingDistanceSection {
        selectedDistance = indexPath.row
        isExpandingDistanceSection = false
        tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
      } else {
        // Expand this section
        isExpandingDistanceSection = true
        tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
      }
    }
    
    if indexPath.section == 2 {
      // Toggle states
      if isExpandingSortBySection {
        selectedSortBy = indexPath.row
        isExpandingSortBySection = false
        tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
      } else {
        // Expand this section
        isExpandingSortBySection = true
        tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
      }
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
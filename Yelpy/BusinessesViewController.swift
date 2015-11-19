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
  
  var businesses: [Business]!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 140
    
    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
      self.businesses = businesses
      self.tableView.reloadData()
      
      MBProgressHUD.hideHUDForView(self.view, animated: true)
      for business in businesses {
        print(business.name! + " @ " + business.address!)
      }
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}

extension BusinessesViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if businesses != nil {
      return businesses.count
    } else {
      return 0
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("businessCell", forIndexPath: indexPath) as! BusinessCell
    
    cell.business = businesses[indexPath.row]
    
    return cell
  }
}

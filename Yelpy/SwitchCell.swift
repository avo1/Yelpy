//
//  SwitchCell.swift
//  Yelpy
//
//  Created by Dave Vo on 11/19/15.
//  Copyright © 2015 Dave Vo. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate {
  optional func switchCell(switchCell: SwitchCell, didChangeValue value: Bool)
}

class SwitchCell: UITableViewCell {
  
  @IBOutlet weak var switchLabel: UILabel!
  @IBOutlet weak var onSwitch: UISwitch!
  
  weak var delegate: SwitchCellDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  @IBAction func onSwitchChange(sender: AnyObject) {
    print("switch changed")
    delegate?.switchCell?(self, didChangeValue: onSwitch.on)
  }
}


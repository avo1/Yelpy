//
//  CheckBoxCell.swift
//  Yelpy
//
//  Created by Dave Vo on 11/21/15.
//  Copyright © 2015 Dave Vo. All rights reserved.
//

import UIKit
import BEMCheckBox

@objc protocol CheckBoxCellDelegate {
  optional func checkBoxCell(checkBoxCell: CheckBoxCell, didChangeValue value: Bool)
}

class CheckBoxCell: UITableViewCell, BEMCheckBoxDelegate {
  
  @IBOutlet weak var checkBoxLabel: UILabel!
  @IBOutlet weak var checkBox: BEMCheckBox!
  
  weak var delegate: CheckBoxCellDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    self.checkBox.delegate = self
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func didTapCheckBox(checkBox: BEMCheckBox) {
    // print("tap on BEMcheckbox")
    delegate?.checkBoxCell?(self, didChangeValue: checkBox.on)
  }
  
}

//
//  BusinessCell.swift
//  Yelpy
//
//  Created by Dave Vo on 11/18/15.
//  Copyright © 2015 Dave Vo. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {
  
  @IBOutlet weak var thumbImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var ratingImageView: UIImageView!
  @IBOutlet weak var reviewsCountLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  
  var business: Business! {
    didSet {
      if business.imageURL != nil {
        thumbImageView.alpha = 0.0
        UIView.animateWithDuration(0.3, animations: {
          self.thumbImageView.setImageWithURL(self.business.imageURL!)
          self.thumbImageView.alpha = 1.0
          }, completion: nil)
      } else {
        thumbImageView.image = UIImage(named: "noImage")
      }
      
      nameLabel.text = business.name
      distanceLabel.text = business.distance
      ratingImageView.setImageWithURL(business.ratingImageURL!)
      reviewsCountLabel.text = "\(business.reviewCount!) reviews"
      addressLabel.text = business.address
      categoryLabel.text = business.categories
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    thumbImageView.layer.cornerRadius = 5
    thumbImageView.clipsToBounds = true
    
    nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
    //    addressLabel.preferredMaxLayoutWidth = addressLabel.frame.size.width
    //    categoryLabel.preferredMaxLayoutWidth = categoryLabel.frame.size.width
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
    //    addressLabel.preferredMaxLayoutWidth = addressLabel.frame.size.width
    //    categoryLabel.preferredMaxLayoutWidth = categoryLabel.frame.size.width
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}

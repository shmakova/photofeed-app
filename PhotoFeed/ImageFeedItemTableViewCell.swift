//
//  ImageFeedItemTableViewCell.swift
//  PhotoFeed
//
//  Created by Mike Spears on 2016-01-08.
//  Copyright © 2016 YourOganisation. All rights reserved.
//

import UIKit

class ImageFeedItemTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var itemImageView: UIImageView!
    
    @IBOutlet weak var itemTitle: UILabel!
    
    weak var dataTask: NSURLSessionDataTask?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

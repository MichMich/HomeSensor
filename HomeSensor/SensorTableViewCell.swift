//
//  SensorTableViewCell.swift
//  HomeSensor
//
//  Created by Michael Teeuw on 15/12/15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import UIKit

class SensorTableViewCell: UITableViewCell {
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var timestampLabel: UILabel!
	@IBOutlet weak var alertIconImageView: UIImageView!
	
	var name:String? {
		didSet {
			updateUI()
		}
	}
	
	var timestamp:NSDate? {
		didSet {
			updateUI()
		}
	}
	
	var state:Bool = false {
		didSet {
			updateUI()
		}
	}
	
	var notificationSubscription:SensorNotificationSubscription = .Off {
		didSet {
			updateUI()
		}
	}
	
	var timestampUpdateTimer:NSTimer?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	private func updateUI() {
		
		nameLabel.text = name
		
		if timestamp != nil {
			updateTimestampLabel()
		} else {
			detailTextLabel?.text = nil
			timestampUpdateTimer?.invalidate()
			timestampUpdateTimer = nil
		}
		
		
		switch notificationSubscription {
			case .Off:
				alertIconImageView.image = UIImage(named: "NotificationOff")
				
			case .Once:
				alertIconImageView.image = UIImage(named: "NotificationOnce")
			
			case .Multiple:
				alertIconImageView.image = UIImage(named: "NotificationMultiple")
		}
		
		if state {
			nameLabel?.textColor = UIColor.whiteColor()
			timestampLabel?.textColor = UIColor(hue: 1, saturation: 0.25, brightness: 1, alpha: 1)
			contentView.backgroundColor = UIColor.redColor()
			
			alertIconImageView.image = alertIconImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
			alertIconImageView.tintColor = UIColor.whiteColor()
		} else {
			nameLabel?.textColor = UIColor.blackColor()
			timestampLabel?.textColor = UIColor.grayColor()
			contentView.backgroundColor = UIColor.whiteColor()
			
			alertIconImageView.image = alertIconImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
			alertIconImageView.tintColor = UIColor(white: 0.3, alpha: 1)
		}
		
	}
	
	func updateTimestampLabel() {
		if let timestamp = timestamp {
			timestampLabel?.text = timestamp.toRelativeFuzzyString()
		}
		
		timestampUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTimestampLabel", userInfo: nil, repeats: false)
	}

}

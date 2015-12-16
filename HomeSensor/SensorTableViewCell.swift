//
//  SensorTableViewCell.swift
//  HomeSensor
//
//  Created by Michael Teeuw on 15/12/15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import UIKit

class SensorTableViewCell: UITableViewCell {
	
	
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
		
		textLabel?.text = name
		
		if timestamp != nil {
			updateTimestampLabel()
		} else {
			detailTextLabel?.text = nil
			timestampUpdateTimer?.invalidate()
			timestampUpdateTimer = nil
		}
		
		if state {
			textLabel?.textColor = UIColor.whiteColor()
			detailTextLabel?.textColor = UIColor(hue: 1, saturation: 0.25, brightness: 1, alpha: 1)
			contentView.backgroundColor = UIColor.redColor()
		} else {
			textLabel?.textColor = UIColor.blackColor()
			detailTextLabel?.textColor = UIColor.grayColor()
			contentView.backgroundColor = UIColor.whiteColor()
		}
		
	}
	
	func updateTimestampLabel() {
		if let timestamp = timestamp, let textString = timestamp.toRelativeString(abbreviated: false, maxUnits: 1) {
			detailTextLabel?.text = (textString != "just now") ? "\(textString) ago." : "\(textString)."
		}
		
		timestampUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "updateTimestampLabel", userInfo: nil, repeats: false)
	}

}

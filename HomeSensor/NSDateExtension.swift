//
//  NSDateExtension.swift
//  HomeSensor
//
//  Created by Michael Teeuw on 18/12/15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import Foundation

extension NSDate {
	
	func toRelativeFuzzyString(fromDate: NSDate = NSDate()) -> String? {
		
		let seconds = fromDate.timeIntervalSinceDate(self)
		
		switch seconds {
			
			case 0..<5:
				return "Just now."
			
			case 5..<20:
				return "A few seconds ago."
			
			case 20..<60:
				return "Less than a minute ago."
			
			case 60..<120:
				return "A minute ago."
			
			default:
				if let timeString = self.toRelativeString(abbreviated: false, maxUnits: 1) {
					return "\(timeString) ago."
				}
		}

		return nil
	}
}
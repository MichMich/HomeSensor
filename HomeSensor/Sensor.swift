//
//  Sensor.swift
//  HomeSensor
//
//  Created by Michael Teeuw on 04/12/15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import Foundation


class Sensor {
	var name: String
	var identifier: String
	var state:Bool = false {
		didSet {
			delegate?.sensorStateUpdate(self, state: state)
		}
	}
	var timestamp:NSDate? {
		didSet {
			delegate?.sensorStateUpdate(self, state: state)
		}
	}
	
	var publishNotificationSubscriptionChange = false
	
	var notificationSubscription:NotificationType = .None {
		didSet {
			if notificationSubscription != oldValue {
				delegate?.sensorNotificationSubscriptionChanged(self, notificationType: notificationSubscription)
			}
		}
	}
	var delegate:SensorDelegateProtocol?
	
	init(name: String, identifier:String) {
		self.name = name
		self.identifier = identifier
	}
	
	func receivedNewValue(value:String) {
		if let boolValue = value.toBool() {
			state = boolValue
		}
	}
	
	func receivedNewTimestamp(timeString:String) {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		timestamp  = dateFormatter.dateFromString(timeString)
	}
}

protocol SensorDelegateProtocol {
	func sensorStateUpdate(sensor:Sensor, state:Bool)
	func sensorNotificationSubscriptionChanged(sensor:Sensor, notificationType:NotificationType)
}

extension String {
	func toBool() -> Bool? {
		switch self.lowercaseString {
		case "true", "yes", "on", "1":
			return true
		case "false", "no", "off", "0":
			return false
		default:
			return nil
		}
	}
}
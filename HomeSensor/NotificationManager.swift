//
//  NotificationManager.swift
//  HomeSensor
//
//  Created by Michael Teeuw on 08/01/16.
//  Copyright © 2016 Michael Teeuw. All rights reserved.
//

import Foundation

enum NotificationType: String {
	case None = "none"
	case Once = "once"
	case Multiple = "multiple"
}

class NotificationManager: NSObject {
	static let sharedInstance = NotificationManager()

	lazy var mqttManager = MQTTManager.sharedInstance
	var deviceToken:String?
	
	override init() {
		super.init()
		
		print("Init NotificationManager")
	}
	
	func registerForNotification(notificationType:NotificationType, device:Device, sensor:Sensor) {
		if let notificationTopic = SensorManager.sharedInstance.topicForNotificationSubscriptionForSensorOnDevice(sensor, onDevice: device) {
			if sensor.publishNotificationSubscriptionChange {
				//print(notificationTopic, ":", notificationType.rawValue)
				mqttManager.publishToTopic(notificationTopic, payload:  notificationType.rawValue)
			}
		} else {
			print("Could not fetch notificationTopic. Maybe no device token set?")
		}
	}
}
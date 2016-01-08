//
//  SensorManager.swift
//  HomeSensor
//
//  Created by Michael Teeuw on 04/12/15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import Foundation
import SwiftDate

class SensorManager: NSObject, DeviceDelegateProtocol {
	static let sharedInstance = SensorManager()
	
	lazy var mqttManager = MQTTManager.sharedInstance
	var devices: [Device] = []
	var delegate:SensorManagerDelegateProtocol?
	
	override init() {
		super.init()
		print("Init SensorManager!" , self)
	}
	
	func addDevice(device:Device) {
		devices.append(device)
		//print("Device: \(device.name) added to SensorManager")
		delegate?.sensorManagerDeviceAdded(self, device: device)
	}
	
	func topicForSensor(sensor:Sensor, onDevice device:Device) -> String {
		return "/device/\(device.identifier)/sensor/\(sensor.identifier)"
	}
	
	func topicForDeviceConnection(device:Device) -> String {
		return "/device/\(device.identifier)/connected"
	}
	
	func topicForNotificationSubscriptionForSensorOnDevice(sensor:Sensor, onDevice device:Device) -> String? {
		if let deviceToken = NotificationManager.sharedInstance.deviceToken {
			return "/subscription/\(deviceToken)/\(device.identifier)/\(sensor.identifier)"
		}
		return nil
	}
	
	private func subscribeSensor(sensor:Sensor, forDevice device:Device) {
		let topic = topicForSensor(sensor, onDevice: device)
		mqttManager.subscribeToTopic(topic)
		mqttManager.subscribeToTopic("\(topic)/timestamp")
		
		if let notificationTopic = topicForNotificationSubscriptionForSensorOnDevice(sensor, onDevice: device) {
			mqttManager.subscribeToTopic(notificationTopic)
		}
	}
	
	private func subscribeDevice(device:Device) {
		let topic = topicForDeviceConnection(device)
		mqttManager.subscribeToTopic(topic)
		mqttManager.subscribeToTopic("\(topic)/timestamp")
	}
	
	func subscribeAll() {
		for device in devices {
			subscribeDevice(device)
			for sensor in device.sensors {
				subscribeSensor(sensor, forDevice: device)
			}
		}
	}
	
}



protocol SensorManagerDelegateProtocol {
	func sensorManagerDeviceAdded(sensorManager:SensorManager, device:Device)
	func sensorManagerDeviceConnectionChanged(sensorManager:SensorManager, device:Device, connected:Bool)
	func sensorManagerDeviceSensorAdded(sensorManager:SensorManager, device:Device, sensor:Sensor)
	func sensorManagerDeviceSensorUpdated(sensorManager:SensorManager, device:Device, sensor:Sensor, state:Bool)
	func sensorManagerDeviceSensorNotificationSubscriptionChanged(sensorManager:SensorManager, device:Device, sensor:Sensor, notificationType:NotificationType)
}

extension SensorManagerDelegateProtocol {
	func sensorManagerDeviceAdded(sensorManager:SensorManager, device:Device) {}
	func sensorManagerDeviceConnectionChanged(sensorManager:SensorManager, device:Device, connected:Bool) {}
	func sensorManagerDeviceSensorAdded(sensorManager:SensorManager, device:Device, sensor:Sensor) {}
	func sensorManagerDeviceSensorUpdated(sensorManager:SensorManager, device:Device, sensor:Sensor, state:Bool) {}
	func sensorManagerDeviceSensorNotificationSubscriptionChanged(sensorManager:SensorManager, device:Device, sensor:Sensor, notificationType:NotificationType) {}
}


// MARK: DeviceDelegateProtocol Methods 
extension SensorManager {
	
	func deviceConnectionChanged(device:Device) {
		delegate?.sensorManagerDeviceConnectionChanged(self, device: device, connected: device.connected)
	}
	
	func deviceSensorAdded(device: Device, sensor: Sensor) {
		subscribeSensor(sensor, forDevice: device)
		delegate?.sensorManagerDeviceSensorAdded(self, device: device, sensor: sensor)
	}
	
	func deviceSensorUpdated(device: Device, sensor: Sensor, state: Bool) {
		delegate?.sensorManagerDeviceSensorUpdated(self, device: device, sensor: sensor, state: state)
	}
	
	func deviceSensorNotificationSubscriptionChanged(device: Device, sensor: Sensor, notificationType: NotificationType) {
		delegate?.sensorManagerDeviceSensorNotificationSubscriptionChanged(self, device: device, sensor: sensor, notificationType: notificationType)
		NotificationManager.sharedInstance.registerForNotification(notificationType, device: device, sensor: sensor)
	}
}

//
//  Device.swift
//  HomeSensor
//
//  Created by Michael Teeuw on 04/12/15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import Foundation

class Device: SensorDelegateProtocol {
	var name: String
	var identifier: String
	var delegate:DeviceDelegateProtocol
	var sensors: [Sensor] = []
	var connected:Bool = false {
		didSet {
			delegate.deviceConnectionChanged(self)
		}
	}
	var timestamp:NSDate? {
		didSet {
			delegate.deviceConnectionChanged(self)
		}
	}
	
	init(name: String, identifier: String, forSensorManager sensorManager:SensorManager) {
		self.name = name
		self.identifier = identifier
		self.delegate = sensorManager
		sensorManager.addDevice(self)
	}
	
	func addSensor(sensor:Sensor) {
		sensor.delegate = self
		sensors.append(sensor)
		delegate.deviceSensorAdded(self, sensor: sensor)
	}
	
	func receivedNewConnectionValue(value:String) {
		if let boolValue = value.toBool() {
			connected = boolValue
		}
	}
	
	func receivedNewConnectionTimestamp(timeString:String) {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		timestamp  = dateFormatter.dateFromString(timeString)
	}
}

// MARK: SensorDelegateProtocol Methods
extension Device {
	func sensorStateUpdate(sensor: Sensor, state: Bool) {
		delegate.deviceSensorUpdated(self, sensor: sensor, state: state)
	}
}

protocol DeviceDelegateProtocol {
	
	func deviceConnectionChanged(device:Device)
	func deviceSensorAdded(device:Device, sensor:Sensor)
	func deviceSensorUpdated(device:Device, sensor:Sensor, state:Bool)
	
}
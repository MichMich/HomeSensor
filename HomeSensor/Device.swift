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
}

// MARK: SensorDelegateProtocol Methods
extension Device {
	func sensorStateUpdate(sensor: Sensor, state: Bool) {
		delegate.deviceSensorUpdated(self, sensor: sensor, state: state)
	}
}

protocol DeviceDelegateProtocol {
	
	func deviceSensorAdded(device:Device, sensor:Sensor)
	func deviceSensorUpdated(device:Device, sensor:Sensor, state:Bool)
	
}
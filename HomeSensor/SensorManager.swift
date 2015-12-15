//
//  SensorManager.swift
//  HomeSensor
//
//  Created by Michael Teeuw on 04/12/15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import Foundation
import SwiftDate



class SensorManager: NSObject, MQTTSessionDelegate, DeviceDelegateProtocol {
	static let sharedInstance = SensorManager()
	
	let mqttSession = MQTTSession(clientId: "HomeSensor", userName: Config.MQTTUsername, password: Config.MQTTPassword)
	var devices: [Device] = []
	
	var delegate:SensorManagerDelegateProtocol?
	
	override init() {
		super.init()
		
		print("Init SensorManager!")
		
		mqttSession.delegate = self
		connect()
		
		print("Init done")
	}
	
	func addDevice(device:Device) {
		devices.append(device)
		//print("Device: \(device.name) added to SensorManager")
		delegate?.sensorManagerDeviceAdded(self, device: device)
	}
	
	func topicForSensor(sensor:Sensor, onDevice device:Device) -> String {
		///device/alarm/sensor/sensor8
		
		return "/device/\(device.identifier)/sensor/\(sensor.identifier)"
	}
	
	func connect() {
		if mqttSession.status != MQTTSessionStatus.Connected && mqttSession.status != MQTTSessionStatus.Connecting {
			mqttSession.connectAndWaitToHost(Config.MQTTHostname, port: Config.MQTTPort, usingSSL: false)
		}
	}
	
}

// MARK: MQTTSessionDelegate Methods
extension SensorManager {
	
	func newMessage(session: MQTTSession!, data: NSData!, onTopic topic: String!, qos: MQTTQosLevel, retained: Bool, mid: UInt32) {
		if let topic = topic, let string = String(data: data, encoding: NSUTF8StringEncoding) {
			for device in devices {
				for sensor in device.sensors {
					let sensorTopic = topicForSensor(sensor, onDevice: device)
					if sensorTopic == topic {
						sensor.receivedNewValue(string)
					} else if "\(sensorTopic)/timestamp" == topic {
						sensor.receivedNewTimestamp(string)
					}
				}
			}
			
		}
	}
	
	func connectionClosed(session: MQTTSession!) {
		connect()
	}
	
}

protocol SensorManagerDelegateProtocol {
	func sensorManagerDeviceAdded(sensorManager:SensorManager, device:Device)
	func sensorManagerDeviceSensorAdded(sensorManager:SensorManager, device:Device, sensor:Sensor)
	func sensorManagerDeviceSensorUpdated(sensorManager:SensorManager, device:Device, sensor:Sensor, state:Bool)
}

extension SensorManagerDelegateProtocol {
	func sensorManagerDeviceAdded(sensorManager:SensorManager, device:Device) {}
	func sensorManagerDeviceSensorAdded(sensorManager:SensorManager, device:Device, sensor:Sensor) {}
	func sensorManagerDeviceSensorUpdated(sensorManager:SensorManager, device:Device, sensor:Sensor, state:Bool) {}
}


// MARK: DeviceDelegateProtocol Methods 
extension SensorManager {
	
	func deviceSensorAdded(device: Device, sensor: Sensor) {
		let topic = topicForSensor(sensor, onDevice: device)
		mqttSession.subscribeToTopic(topic, atLevel: MQTTQosLevel.AtLeastOnce)
		mqttSession.subscribeToTopic("\(topic)/timestamp", atLevel: MQTTQosLevel.AtLeastOnce)

		delegate?.sensorManagerDeviceSensorAdded(self, device: device, sensor: sensor)
	}
	
	func deviceSensorUpdated(device: Device, sensor: Sensor, state: Bool) {
		delegate?.sensorManagerDeviceSensorUpdated(self, device: device, sensor: sensor, state: state)
	}
}

//
//  MQTTManager.swift
//  HomeSensor
//
//  Created by Michael Teeuw on 08/01/16.
//  Copyright © 2016 Michael Teeuw. All rights reserved.
//

import Foundation

class MQTTManager: NSObject, MQTTSessionDelegate {
	static let sharedInstance = MQTTManager()

	lazy var sensorManager = SensorManager.sharedInstance
	let mqttSession = MQTTSession(clientId: "HomeSensor", userName: Config.MQTTUsername, password: Config.MQTTPassword)

	override init() {
		super.init()
		print("Init MQTT manager")
		mqttSession.delegate = self
		connect()
	}
	
	func connect() {
		if mqttSession.status != MQTTSessionStatus.Connected && mqttSession.status != MQTTSessionStatus.Connecting {
			print("Connecting ...")
			mqttSession.connectToHost(Config.MQTTHostname, port: Config.MQTTPort, usingSSL: false)
		}
	}
}

// MARK: MQTTSessionDelegate Methods
extension MQTTManager {
	
	func newMessage(session: MQTTSession!, data: NSData!, onTopic topic: String!, qos: MQTTQosLevel, retained: Bool, mid: UInt32) {
		if let topic = topic, let string = String(data: data, encoding: NSUTF8StringEncoding) {
			
			print(topic, string)
			
			for device in sensorManager.devices {
				
				let deviceConnectedTopic = sensorManager.topicForDeviceConnection(device)
				if deviceConnectedTopic == topic {
					device.receivedNewConnectionValue(string)
				} else if "\(deviceConnectedTopic)/timestamp" == topic {
					device.receivedNewConnectionTimestamp(string)
				}
				
				for sensor in device.sensors {
					let sensorTopic = sensorManager.topicForSensor(sensor, onDevice: device)
					if sensorTopic == topic {
						sensor.receivedNewValue(string)
					} else if "\(sensorTopic)/timestamp" == topic {
						sensor.receivedNewTimestamp(string)
					}
					
					if let notificationTopic = sensorManager.topicForNotificationSubscriptionForSensorOnDevice(sensor, onDevice: device) {
						if notificationTopic == topic {
							if let notificationType = NotificationType(rawValue: string) {
								sensor.publishNotificationSubscriptionChange = false
								sensor.notificationSubscription = notificationType
							}
						}
					}
				}
			}
		}
	}
	
	func connectionClosed(session: MQTTSession!) {
		connect()
	}
	
	func connected(session: MQTTSession!) {
		sensorManager.subscribeAll()
		print("Connected to MQTT server.")
	}
	
	func subscribeToTopic(topic:String) {
		mqttSession.subscribeToTopic(topic, atLevel: MQTTQosLevel.AtLeastOnce)
	}
	
	func publishToTopic(topic:String, payload:String) {
		print("Publish: ", topic, ": ", payload)
		mqttSession.publishData(payload.dataUsingEncoding(NSUTF8StringEncoding), onTopic: topic, retain: true, qos: .AtLeastOnce)
	}
	
}
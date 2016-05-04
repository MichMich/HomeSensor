//
//  MQTTManager.swift
//  HomeSensor
//
//  Created by Michael Teeuw on 08/01/16.
//  Copyright © 2016 Michael Teeuw. All rights reserved.
//

import Foundation
import CocoaMQTT

class MQTTManager: NSObject, CocoaMQTTDelegate {
	static let sharedInstance = MQTTManager()

    var delegate:MQTTManagerDelegate?
	lazy var sensorManager = SensorManager.sharedInstance
    let mqtt = CocoaMQTT(clientId: "HomeSensor-" + String(NSProcessInfo().processIdentifier), host: Config.MQTTHostname, port: Config.MQTTPort)
    var connected = false {
        didSet {
            delegate?.mqttManagerConnectionChanged(self)
        }
    }
    
	override init() {
		super.init()
		print("Init MQTT manager")
        mqtt.username = Config.MQTTUsername
        mqtt.password = Config.MQTTPassword
        mqtt.keepAlive = 60
        mqtt.delegate = self

		connect()
	}
	
	func connect() {
        if mqtt.connState != .CONNECTED && mqtt.connState != .CONNECTING {
            mqtt.connect();
        }
	}
}

// MARK: CocoaMQTTDelegate Methods
extension MQTTManager {
    
    

    
    func mqtt(mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {}
    
    func mqtt(mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {}
    
    func mqtt(mqtt: CocoaMQTT, didPublishAck id: UInt16) {}
    
    func mqtt(mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        print("Subscribed to topic: ", topic)
    }
    
    func mqtt(mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {}
    
    func mqttDidPing(mqtt: CocoaMQTT) {
        print("Ping!")
    }
    
    func mqttDidReceivePong(mqtt: CocoaMQTT) {
        print("Pong!")
    }
    
    func mqttDidDisconnect(mqtt: CocoaMQTT, withError err: NSError?) {
        print("Disconnected from MQTT!",err)
        connected = false
        connect()
    }

    func mqtt(mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        print("Connected to MQTT server.")
        connected = true
        sensorManager.subscribeAll()
    }
    
    func mqtt(mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        if let string = message.string {
            
            print(message.topic, string)
            
            for device in sensorManager.devices {
                
                let deviceConnectedTopic = sensorManager.topicForDeviceConnection(device)
                if deviceConnectedTopic == message.topic {
                    device.receivedNewConnectionValue(string)
                } else if "\(deviceConnectedTopic)/timestamp" == message.topic {
                    device.receivedNewConnectionTimestamp(string)
                }
                
                for sensor in device.sensors {
                    let sensorTopic = sensorManager.topicForSensor(sensor, onDevice: device)
                    if sensorTopic == message.topic {
                        sensor.receivedNewValue(string)
                    } else if "\(sensorTopic)/timestamp" == message.topic {
                        sensor.receivedNewTimestamp(string)
                    }
                    
                    if let notificationTopic = sensorManager.topicForNotificationSubscriptionForSensorOnDevice(sensor, onDevice: device) {
                        if notificationTopic == message.topic {
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
 
	
	func subscribeToTopic(topic:String) {
        if mqtt.connState == .CONNECTED {
            print("Subscribe to: ", topic)
            mqtt.subscribe(topic, qos: CocoaMQTTQOS.QOS1)
        } else {
            print("Can't subscribe to \(topic). Not connected.")
        }
        
	}
	
	func publishToTopic(topic:String, payload:String) {
        if mqtt.connState == .CONNECTED {
            print("Publish: ", topic, ": ", payload)
            mqtt.publish(topic, withString: payload, qos: CocoaMQTTQOS.QOS1, retained: true, dup: true)
        } else {
            print("Can't publish to \(topic). Not connected.")
        }
	}
 
	
}

protocol MQTTManagerDelegate {
    func mqttManagerConnectionChanged(mqttManager:MQTTManager)
}
//
//  TableViewController.swift
//  HomeSensor
//
//  Created by Michael Teeuw on 11/12/15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, SensorManagerDelegateProtocol {
	
	let sensorManager = SensorManager.sharedInstance
	var footerUpdateTimer:NSTimer? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
		
		print("Table view controller loaded.")

		sensorManager.delegate = self
		
		let alarm = Device(name: "Alarm", identifier: "alarm", forSensorManager: SensorManager.sharedInstance)
		
		alarm.addSensor(Sensor(name: "Door", identifier: "door"))
		alarm.addSensor(Sensor(name: "Hallway", identifier: "hallway"))
		alarm.addSensor(Sensor(name: "Livingroom", identifier: "livingroom"))
		alarm.addSensor(Sensor(name: "Bedroom", identifier: "bedroom"))
		alarm.addSensor(Sensor(name: "Kidsroom", identifier: "kidsroom"))
		
		let dishwasher = Device(name: "Dishwasher", identifier: "dishwasher", forSensorManager: SensorManager.sharedInstance)
		
		dishwasher.addSensor(Sensor(name: "Ready", identifier: "ready"))
		
		sensorManager.mqttSession.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
		
		// footerUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateConnectionDetails", userInfo: nil, repeats: true)
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sensorManager.devices.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sensorManager.devices[section].sensors.count
    }
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sensorManager.devices[section].name
	}
	
	override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		
		tableView.footerViewForSection(section)?.textLabel?.font = UIFont.systemFontOfSize(10)
		
		return stringForSectionFooter(section)
	}
	
	func stringForSectionFooter(section:Int) -> String {
		let connectionString = sensorManager.devices[section].connected ? "Connected" : "Disconnected"
		if let timestamp = sensorManager.devices[section].timestamp, let timeString = timestamp.toRelativeFuzzyString() {
			return "\(connectionString) \(timeString.lowercaseString)"
		}
		return connectionString
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SensorTableViewCell
		let sensor = sensorManager.devices[indexPath.section].sensors[indexPath.row]
		
		cell.state = sensor.state
		cell.name = sensor.name
		cell.timestamp = sensor.timestamp
		
		return cell
	}
	
	private func reloadSensor(updatedSensor:Sensor) {
		for (section, device) in sensorManager.devices.enumerate() {
			for (row, sensor) in device.sensors.enumerate() {
				if updatedSensor.identifier == sensor.identifier {
					let indexPath = NSIndexPath(forRow: row, inSection: section)
					tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
				}
			}
		}
	}
	
/*
	func updateConnectionDetails() {
		if let visibleIndexPaths = tableView.indexPathsForVisibleRows {
			for indexPath in visibleIndexPaths {
				if let label = tableView.footerViewForSection(indexPath.section)?.textLabel {
					label.text = stringForSectionFooter(indexPath.section)
					label.sizeToFit()
				}
			}
		}
	}
*/
	
	override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
		
		var statusString = "Unknown"
		
		switch sensorManager.mqttSession.status {
			case .Created:
				statusString = "Created"
			case .Connecting:
				statusString = "Connecting"
			case .Connected:
				statusString = "Connected"
			case .Disconnecting:
				statusString = "Disconnecting"
			case .Closed:
				statusString = "Closed"
			case .Error:
				statusString = "Error"
		}
		
		print("Connection status: ", statusString)
		
		title = "HomeSensor \(statusString)"
	}

}

// MARK: SensorManagerDelegateProtocol Methods
extension TableViewController {
	
	func sensorManagerDeviceAdded(sensorManager: SensorManager, device: Device) {
		tableView.reloadData()
		print("Sensor manager: \(sensorManager) - Device added: \(device.name)")
	}
	
	func sensorManagerDeviceConnectionChanged(sensorManager: SensorManager, device: Device, connected:Bool) {
		tableView.reloadData()
		print("Sensor manager: \(sensorManager) - Device connection changed: \(device.name) - Connected: \(connected)")
	}
	
	func sensorManagerDeviceSensorAdded(sensorManager: SensorManager, device: Device, sensor: Sensor) {
		tableView.reloadData()
		print("Sensor manager: \(sensorManager) - Device: \(device.name) - Sensor added: \(sensor.name)")
	}
	
	func sensorManagerDeviceSensorUpdated(sensorManager: SensorManager, device: Device, sensor: Sensor, state: Bool) {
		reloadSensor(sensor)
		print("Sensor manager: \(sensorManager) - Device: \(device.name) - Sensor: \(sensor.name) - Value: \(state)")
	}
}

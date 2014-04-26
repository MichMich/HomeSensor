var apn = require('apn');
	

function PushNotifier() {
	var options = {
		errorCallback: function(err, notif) {
			console.log('ERROR : ' + err + '\nNOTIFICATION : ' + notif);
		}
	};
	var apnConnection = new apn.Connection(options);
	
	this.sendNotification = function (deviceToken,message,sound)
	{

		var isHex = /[a-fA-F0-9]{16}/;
		if (!isHex.test(deviceToken)) {
			console.log('No valid hexkey: '+deviceToken);
			return false;
		}

		var myDevice = new apn.Device(deviceToken);
		var notification = new apn.Notification();

		notification.expiry = Math.floor(Date.now() / 1000) + 3600 * 24; // Expires 1 hour from now.
		notification.badge = 0;
		notification.sound = (sound) ? sound : "ping.aiff";
		notification.alert = message;
		notification.payload = {};

		apnConnection.pushNotification(notification, myDevice);

		console.log(myDevice);
		console.log('Notification "'+message+'" sent to: '+myDevice);
		//console.log(notification);
	}
}

module.exports = new PushNotifier;
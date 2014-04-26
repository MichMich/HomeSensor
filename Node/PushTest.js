var express = require("express");
var app = express();



var events = [];

events.push({description:"Vaatwasser is klaar.", timestamp:Math.round(Date.now()/1000)});
events.push({description:"Vaatwasser is klaar.", timestamp:Math.round(Date.now()/1000)});
events.push({description:"Vaatwasser is klaar.", timestamp:Math.round(Date.now()/1000)});
events.push({description:"Hoppa.", timestamp:Math.round(Date.now()/1000)});

/* serves main page */
app.get("/", function(req, res) {
	res.send(JSON.stringify(events));
});

app.get("/send", function(req, res) {
	sendNotification();
	res.send("done");
});

app.listen(8081, function() {
	console.log("Listening on 8081");
});




var apn = require('apn');
var apnConnection = new apn.Connection({});
var myDevice = new apn.Device("b6d24f7f0f7047e598cec35279b1748986033f71b2200a900637dfbed4359c8e");







function sendNotification() {
	var note = new apn.Notification();

	note.expiry = Math.floor(Date.now() / 1000) + 3600 * 24; // Expires 1 hour from now.
	note.badge = "+1";
	note.sound = "ready.aiff";
	note.alert = "Vaatwasser is klaar.";
	note.payload = {};

	apnConnection.pushNotification(note, myDevice);

};


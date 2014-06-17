process.env['DEBUG'] = 'apn';



var express = require("express");
var url = require('url');
var app = express();
var socket = require("socket.io-client");

var EventDispatcher = require("./EventDispatcher");

EventDispatcher.registerEvent('app_restart', 'HomeSensor restarted.', 'app_restart.aiff', 'app_restart.png');
EventDispatcher.registerEvent('dishwasher_ready', 'Vaatwasser is klaar.', 'dishwasher_ready.aiff', 'dishwasher_ready.png');
EventDispatcher.registerEvent('dishwasher_reset', 'Vaatwasser is gereset.', 'dishwasher_reset.aiff', 'dishwasher_reset.png');
EventDispatcher.registerEvent('plant_needswater', 'Plant heeft water nodig.', 'plant_needswater.aiff', 'plant_needswater.png');
EventDispatcher.registerEvent('plant_haswater', 'Plant heeft voldoende water.', 'plant_haswater.aiff', 'plant_haswater.png');
EventDispatcher.registerEvent('alarm_door', 'Voordeur geopend.', 'alarm_door.aiff', 'alarm_door.png');
EventDispatcher.registerEvent('alarm_hallway', 'Beweging in de gang.', 'alarm_hallway.aiff', 'alarm_hallway.png');
EventDispatcher.registerEvent('alarm_livingroom', 'Beweging in de woonkamer.', 'alarm_livingroom.aiff', 'alarm_livingroom.png');
EventDispatcher.registerEvent('alarm_bedroom', 'Beweging in de slaapkamer.', 'alarm_bedroom.aiff', 'alarm_bedroom.png');
EventDispatcher.registerEvent('alarm_spareroom', 'Beweging in de zijkamer.', 'alarm_spareroom.aiff', 'alarm_spareroom.png');


EventDispatcher.getEvent('app_restart').subscribe('b6d24f7f0f7047e598cec35279b1748986033f71b2200a900637dfbed4359c8e', false);
EventDispatcher.fireEvent('app_restart');




/* Xbee Monitor */

var xbee = socket.connect('http://localhost:8082');
xbee.on('dishwasher', function (dishwasherDone) {
	if (dishwasherDone) {
		EventDispatcher.fireEvent('dishwasher_ready');
	} else {
		EventDispatcher.fireEvent('dishwasher_reset');
	}
});
xbee.on('plantNeedsWater', function (plantNeedsWater) {
	if (plantNeedsWater) {
		EventDispatcher.fireEvent('plant_needswater');
	} else {
		EventDispatcher.fireEvent('plant_haswater');
	}
});

/* Alarm Monitor */

var alarm = socket.connect('http://rpi-alarm.local:8080');
alarm.on('sensor', function (sensor) {
	if (sensor.state) {
		EventDispatcher.fireEvent('alarm_'+sensor.identifier);
	}
});




/* serves main page */
app.get("/", function(request, response) {
	response.send(JSON.stringify(events));
});

app.get("/api/registered_events", function(request, response) {
	var url_parts = url.parse(request.url, true);
	var query = url_parts.query;

	console.log("Request for registered_events by: "+query.deviceToken);

	response.send(JSON.stringify(EventDispatcher.registeredEvents(query.deviceToken)));
});

app.get("/api/event_history", function(request, response) {
	response.send(JSON.stringify(EventDispatcher.eventHistory()));
});


app.get('/api/subscribe', function(request,response) {
	var url_parts = url.parse(request.url, true);
	var query = url_parts.query;

	var repeat = (query.repeat == 'true') ? true : false;
	var event = EventDispatcher.getEvent(query.event);
	var deviceToken = query.deviceToken;
	if (event && deviceToken) {
		var success = event.subscribe(deviceToken, repeat);
		response.send(JSON.stringify({success:success}));	
	} else {
		response.send(JSON.stringify({success:false}));	
	}
});

app.get('/api/unsubscribe', function(request,response) {
	var url_parts = url.parse(request.url, true);
	var query = url_parts.query;

	var event = EventDispatcher.getEvent(query.event);
	var deviceToken = query.deviceToken;
	if (event && deviceToken) {
		event.unsubscribe(deviceToken);
		event.dumpSubscribers();
		response.send(JSON.stringify({success:true}));	
	} else {
		response.send(JSON.stringify({success:false}));	
	}
});

app.get("/fire", function(request, response) {	
	var url_parts = url.parse(request.url, true);
	var query = url_parts.query;

	var success = EventDispatcher.fireEvent(query.type);
	response.send(JSON.stringify({success:success}));
});

app.listen(8081, function() {
	console.log("Listening on 8081");
});









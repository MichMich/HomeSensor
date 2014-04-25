var express = require("express");
var url = require('url');
var app = express();


var EventDispatcher = require("./EventDispatcher");

EventDispatcher.registerEvent('dishwasher_ready', 'Vaatwasser is klaar.', 'ready.aiff', 'dishwasher.png');
EventDispatcher.registerEvent('dishwasher_reset', 'Vaatwasser is gereset.', false, 'dishwasher.png');


var PushNotifier = require('./PushNotifier');
//PushNotifier.sendNotification('b6d24f7f0f7047e598cec35279b1748986033f71b2200a900637dfbed4359c8e',"Test Message",false);




EventDispatcher.getEvent('dishwasher_ready').subscribe('b6d24f7f0f7047e598cec35279b1748986033f71b2200a900637dfbed4359c8e', true);
EventDispatcher.getEvent('dishwasher_ready').subscribe('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', false);
EventDispatcher.getEvent('dishwasher_ready').subscribe('1234567890123456789123456789012345678923456789234567834567845677', false);


EventDispatcher.fireEvent('dishwasher_ready');
EventDispatcher.fireEvent('dishwasher_ready');



/* serves main page */
app.get("/", function(request, response) {
	response.send(JSON.stringify(events));
});

app.get("/api/registered_events", function(request, response) {
	response.send(JSON.stringify(EventDispatcher.registeredEvents()));
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









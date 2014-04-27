var Event = require("./Event");

function EventDispatcher() {
	var registeredEvents = [];
	var eventHistory = [];

	this.registerEvent = function(identifier, description, sound, icon) {

		var event = this.getEvent(identifier);
	
		if (!event) {
			event = new Event();
			registeredEvents.push(event);
		}

		event.identifier(identifier);
		event.description(description);
		event.sound(sound);
		event.icon(icon);

		return event;
	}

	this.registeredEvents = function(deviceToken) {

		var events = [];

		for (var i in registeredEvents) {
			var event = registeredEvents[i];

			var eventObject = event.publicObject();
			var subscribed = event.subscriberDetails(deviceToken);

			eventObject.subscribed = subscribed.subscribed;
			eventObject.repeat = subscribed.repeat;
					
			events.push(eventObject);
		}

		return events;
	}

	this.eventHistory = function() {

		var events = [];

		for (var i in eventHistory) {
			var event = eventHistory[i];
			
			events.push({event:event.event.publicObject(), timestamp:event.timestamp});
		}

		return events;
	}

	this.getEvent = function(identifier) {
		for (var i in registeredEvents) {
			var event = registeredEvents[i];
			if (event.identifier() == identifier) {
				return event;
			}
		}
		return false;
	}

	this.fireEvent = function(identifier) {
		var event = this.getEvent(identifier);
		if (!event) {
			return false;
		}
		eventHistory.push({event: this.getEvent(identifier), timestamp: Date.now()});

		//cleanup event history
		if (eventHistory.length > 250) {
			newEventHistory = eventHistory.slice(eventHistory.length - 250);
			eventHistory = newEventHistory;
		}

		event.fire();
		return true;
	}
}


module.exports = new EventDispatcher;
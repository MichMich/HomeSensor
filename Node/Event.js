var PushNotifier = require('./PushNotifier');

console.log(PushNotifier);

function Event() {

	var identifier,
		description,
		sound,
		icon;

	var subscribers = [];

	//getters & setters
	this.identifier = function()
	{
		if (arguments.length === 1) {
			identifier = arguments[0];
		} else {
			return identifier;
		}
	}

	this.description = function()
	{
		if (arguments.length === 1) {
			description = arguments[0];
		} else {
			return description;
		}
	}

	this.sound = function()
	{
		if (arguments.length === 1) {
			sound = arguments[0];
		} else {
			return sound;
		}
	}

	this.icon = function()
	{
		if (arguments.length === 1) {
			icon = arguments[0];
		} else {
			return icon;
		}
	}

	this.fire = function() 
	{
		console.log('Event fired: ' + this.identifier());

		var currentSubscriber = subscribers;
		
		for (var i in currentSubscriber) {
			var subscriber = currentSubscriber[i];
			PushNotifier.sendNotification(subscriber.deviceToken,this.description(), this.sound());
			if (!subscriber.repeat) {
				this.unsubscribe(subscriber.deviceToken);
			}
		}
	}

	this.subscribe =  function(deviceToken, repeat)
	{
		var isHex = /[a-fA-F0-9]{16}/;
		if (!isHex.test(deviceToken)) {
			console.log('No valid hexkey: '+deviceToken);
			return false;
		}

		this.unsubscribe(deviceToken);
		console.log('Subscribe ' + this.identifier() + ' by ' + deviceToken + ' - Repeat: ' + repeat);
		subscribers.push({deviceToken:deviceToken, repeat:repeat});

		return true;
	}

	this.unsubscribe = function(deviceToken)
	{
		var newSubscribers = [];
		for (var i in subscribers) {
			var subscriber = subscribers[i];
			if (subscriber.deviceToken != deviceToken) {
				newSubscribers.push(subscriber);
			} else {
				console.log('Unsubscribe ' + this.identifier() + ' by ' + deviceToken);
			}
		}
		subscribers = newSubscribers;
	}

	this.subscriberDetails = function(deviceToken)
	{
		for (var i in subscribers) {
			var subscriber = subscribers[i];
			if (subscriber.deviceToken == deviceToken) {
				return {subscribed:true, repeat:subscriber.repeat};
			}
		}
		return {subscribed:false, repeat:null};
	}

	this.dumpSubscribers = function()
	{
		console.log('subscribers for '+this.identifier()+': ');
		for (var i in subscribers) {
			console.log(subscribers[i]);
		}
	}

}


Event.prototype.publicObject = function() 
{
	return { identifier:this.identifier(),description:this.description(),sound:this.sound(),icon:this.icon()};
}


module.exports = Event;
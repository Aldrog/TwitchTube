/*
 * Copyright © 2015 Andrew Penkrat
 *
 * This file is part of TwitchTube.
 *
 * TwitchTube is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * TwitchTube is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with TwitchTube.  If not, see <http://www.gnu.org/licenses/>.
 */

var user_specs = []
var spec_icons
var user_colors = []
var default_colors = [
			["Red", "#FF0000"],
			["Blue", "#0000FF"],
			["Green", "#00FF00"],
			["FireBrick", "#B22222"],
			["Coral", "#FF7F50"],
			["YellowGreen", "#9ACD32"],
			["OrangeRed", "#FF4500"],
			["SeaGreen", "#2E8B57"],
			["GoldenRod", "#DAA520"],
			["Chocolate", "#D2691E"],
			["CadetBlue", "#5F9EA0"],
			["DodgerBlue", "#1E90FF"],
			["HotPink", "#FF69B4"],
			["BlueViolet", "#8A2BE2"],
			["SpringGreen", "#00FF7F"]]

function getColor(name) {
	var color;
	if(user_colors[name]) { //Cached from USERCOLOR notices
		color = user_colors[name];
	} else {
		var n = name.charCodeAt(0) + name.charCodeAt(name.length - 1);
		color = default_colors[n % default_colors.length][1]
	}
	return color;
}

function setColor(name, color) {
	user_colors[name] = color
}

function parseEmoticons(nick, str) {
	var res = str
	if(nick) {
		HTTP.getRequest("https://api.twitch.tv/kraken/chat/" + nick + "/emoticons", function(data) {
			if(data) {
				var emoticons = JSON.parse(data).emoticons
				for (var i in emoticons) {
					res = res.replace(new RegExp(emoticons[i].regex, 'g'), "<img src='" + emoticons[i].url + "'/>")
				}
				console.log(res)
				messages.insert(0, {badges: parseBadges(nick), nick: nick, nick_color: getColor(nick), message: res})
			}
			else {
				messages.insert(0, {badges: parseBadges(nick), nick: nick, nick_color: getColor(nick), message: res})
			}
		})
	}
	else
		messages.insert(0, {badges: "", nick: nick, nick_color: "#000000", message: res})
}

function addSpec(name, spec) {
	if(!user_specs[name])
		user_specs[name] = []
	user_specs[name][spec] = 1
}

function rmSpec(name, spec) {
	if(user_specs[name][spec])
		delete user_specs[name][spec]
}

function parseBadges(name) {
	var res = ""
	if(name === channel)
		res += "<img src='" + spec_icons.broadcaster.image + "'/> "
	for(var i in user_specs[name]) {
		console.log(i)
		res += "<img src='" + spec_icons[i].image + "'/> "
	}
	return res
}

function init() {
	twitchChat.join(channel)

	HTTP.getRequest("https://api.twitch.tv/kraken/chat/" + channel + "/badges", function(data) {
		if(data) {
			spec_icons = JSON.parse(data)
			for(var x in spec_icons) {
				console.log(x)
				for(var i in spec_icons[x])
					console.log(i, ' ', spec_icons[x][i])
			}
		}
	})
}

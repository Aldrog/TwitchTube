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

var usercolors = []
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
	if(usercolors[name]) { //Cached from USERCOLOR notices
		color = usercolors[name];
	} else {
		var n = name.charCodeAt(0) + name.charCodeAt(name.length - 1);
		color = default_colors[n % default_colors.length][1]
	}
	return color;
}

function setColor(name, color) {
	usercolors[name] = color
}

function parseEmoticons(nick, str) {
	var res = str
	HTTP.getRequest("https://api.twitch.tv/kraken/chat/" + nick + "/emoticons", function(data) {
		var emoticons = JSON.parse(data).emoticons
		for (var i in emoticons) {
			res = res.replace(new RegExp(emoticons[i].regex, 'g'), "<img src='" + emoticons[i].url + "'/>")
		}
		console.log(res)
		messages.insert(0, {nick: nick, nick_color: getColor(nick), message: res})
	})
}

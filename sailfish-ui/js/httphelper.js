/*
 * Copyright © 2015-2016 Andrew Penkrat
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
.pragma library

function getRequest(url, callback, publicAPI) {
	var request = new XMLHttpRequest()
    request.open("GET", url)
    if(url.indexOf("https://api.twitch.tv/kraken") === 0) {
        // Kraken API
        request.setRequestHeader("Accept", "application/vnd.twitchtv.v3+json")
        request.setRequestHeader("Client-ID", "n57dx0ypqy48ogn1ac08buvoe13bnsu")
    } else if(publicAPI) {
        // Experimental API
        request.setRequestHeader("Accept", "application/vnd.twitchtv.v3+json")
        request.setRequestHeader("Client-ID", "n57dx0ypqy48ogn1ac08buvoe13bnsu")
    }
	request.onreadystatechange = function() {
		if (request.readyState === XMLHttpRequest.DONE) {
            if (request.status && request.status === 200) {
                callback(request.responseText, false)
			} else {
				console.log("Error accessing url", url)
				console.log("HTTP:", request.status, request.statusText)
                callback(false, request.status)
			}
		}
	}
	request.send()
}

function putRequest(url, callback, publicAPI) {
	var request = new XMLHttpRequest()
    request.open("PUT", url)
    if(url.indexOf("https://api.twitch.tv/kraken") === 0) {
        // Kraken API
        request.setRequestHeader("Accept", "application/vnd.twitchtv.v3+json")
        request.setRequestHeader("Client-ID", "n57dx0ypqy48ogn1ac08buvoe13bnsu")
    } else if(publicAPI) {
        // Experimental API
        request.setRequestHeader("Accept", "application/vnd.twitchtv.v3+json")
        request.setRequestHeader("Client-ID", "n57dx0ypqy48ogn1ac08buvoe13bnsu")
    }
	request.onreadystatechange = function() {
		if (request.readyState === XMLHttpRequest.DONE) {
			if (request.status && request.status === 200) {
                callback(request.responseText)
			} else {
				console.log("HTTP:", request.status, request.statusText)
                callback(false)
			}
		}
	}
	request.send()
}

function deleteRequest(url, callback, publicAPI) {
	var request = new XMLHttpRequest()
    request.open("DELETE", url)
    if(url.indexOf("https://api.twitch.tv/kraken") === 0) {
        // Kraken API
        request.setRequestHeader("Accept", "application/vnd.twitchtv.v3+json")
        request.setRequestHeader("Client-ID", "n57dx0ypqy48ogn1ac08buvoe13bnsu")
    } else if(publicAPI) {
        // Experimental API
        request.setRequestHeader("Accept", "application/vnd.twitchtv.v3+json")
        request.setRequestHeader("Client-ID", "n57dx0ypqy48ogn1ac08buvoe13bnsu")
    }
	request.onreadystatechange = function() {
		if (request.readyState === XMLHttpRequest.DONE) {
			if (request.status && request.status === 200) {
				callback(request.responseText)
			} else {
				console.log("HTTP:", request.status, request.statusText)
				callback(request.status)
			}
		}
	}
	request.send()
}

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
.pragma library

function getRequest(url, callback) {
	var request = new XMLHttpRequest()
	request.open('GET', url)
	request.onreadystatechange = function() {
		if (request.readyState === XMLHttpRequest.DONE) {
			if (request.status && request.status === 200) {
				//console.log("response", request.responseText)
				callback(request.responseText)
			} else {
				console.log("Error accessing url", url)
				console.log("HTTP:", request.status, request.statusText)
				callback(false)
			}
		}
	}
	request.send()
}

function putRequest(url, callback) {
	var request = new XMLHttpRequest()
	request.open('PUT', url)
	request.onreadystatechange = function() {
		if (request.readyState === XMLHttpRequest.DONE) {
			if (request.status && request.status === 200) {
				console.log("response", request.responseText)
				callback(request.responseText)
			} else {
				console.log("HTTP:", request.status, request.statusText)
				callback(false)
			}
		}
	}
	request.send()
}

function deleteRequest(url, callback) {
	var request = new XMLHttpRequest()
	request.open('DELETE', url)
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

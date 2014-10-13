import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0

Page {
	id: page

	property var token
	function getToken() {
		var request = new XMLHttpRequest()
		request.open('GET', 'https://api.twitch.tv/api/channels/versuta/access_token')
		request.onreadystatechange = function() {
			if (request.readyState === XMLHttpRequest.DONE) {
				if (request.status && request.status === 200) {
					console.log("response", request.responseText)
					//var result = JSON.parse(request.responseText)
					//page.token = result.response
					page.token = JSON.parse(request.responseText)
					getURL()
				} else {
					console.log("HTTPS:", request.status, request.statusText)
				}
			}
		}
		//request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
		request.send()
	}
	property var url
	function getURL() {
		var request = new XMLHttpRequest()
		request.open('GET', encodeURI('https://usher.twitch.tv/select/versuta.json?nauthsig=' + page.token.sig + '&nauth=' + page.token.token))
		request.onreadystatechange = function() {
			if (request.readyState === XMLHttpRequest.DONE) {
				if (request.status && request.status === 200) {
					console.log("response", request.responseText)
					var result = JSON.parse(request.responseText)
					page.url = result.response
				} else {
					console.log("HTTPS:", request.status, request.statusText)
				}
			}
		}
		//request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
		request.send()
	}

    MediaPlayer {
		id: player

		source: url['url']
        autoPlay: true
    }

    VideoOutput {
        id: streamVideo
        source: player
        anchors.fill: parent
    }
	Component.onCompleted: {
		getToken();
	}
}

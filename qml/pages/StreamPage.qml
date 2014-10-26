import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0

Page {
	id: page

	//property var token
	function getPlaylist() {
		var request = new XMLHttpRequest()
		request.open('GET', 'https://api.twitch.tv/api/channels/dotastarladder_en/access_token')
		request.onreadystatechange = function() {
			if (request.readyState === XMLHttpRequest.DONE) {
				if (request.status && request.status === 200) {
					console.log("response", request.responseText)
					var result = JSON.parse(request.responseText)
					//page.token = result
					//page.token = JSON.parse(request.responseText)
					for (var x in result)
						console.log(x)
					getURLFromToken(result)
				} else {
					console.log("HTTPS:", request.status, request.statusText)
				}
			}
		}
		//request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
		request.send()
	}
	property var playlist
	function getURLFromToken(token) {
		var request = new XMLHttpRequest()
		var url = 'https://usher.twitch.tv/select/starladder.json?nauthsig=' + encodeURI(token.sig) + '&nauth=' + crypto.createHmac(token.token)
		console.log(url)
		request.open('GET', url)
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

		source: url.url
        autoPlay: true
    }

    VideoOutput {
        id: streamVideo
        source: player
        anchors.fill: parent
    }
	Component.onCompleted: {
		getPlaylist()();
	}
}

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import 'scripts/httphelper.js' as HTTP

Page {
	id: page

	property var url
	property string channel

	function searchURL(s, q) {
		for (var x in s) {
			if (s[x].substring(0,4) === 'http' && s[x].indexOf(q) >= 0)
				return s[x]
		}
	}

	Video {
		id: stream
		anchors.fill: parent
		source: url['high']
		MouseArea {
			anchors.fill: parent
			onClicked: {
				console.log("starting")
				stream.play()
			}
		}
	}

	Component.onCompleted: {
		HTTP.getRequest('http://api.twitch.tv/api/channels/' + channel + '/access_token', function (tokendata) {
			if (tokendata) {
				var token = JSON.parse(tokendata)
				HTTP.getRequest(encodeURI('http://usher.twitch.tv/select/' + channel + '.json?allow_source=true&nauthsig=' + token.sig + '&nauth=' + token.token + '&type=any'), function (data) {
					if (data) {
						var video = data.split('\n')
						url = {
							source: searchURL(video, "source"),
							high: searchURL(video, "high"),
							medium: searchURL(video, "medium"),
							low: searchURL(video, "low"),
							mobile: searchURL(video, "mobile")
						}
					}
				})
			}
		})
	}
}

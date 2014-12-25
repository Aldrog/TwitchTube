import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import Sailfish.Media 1.0
import "scripts/httphelper.js" as HTTP

Page {
	id: page

	property var url
	property string channel
	property string quality: "high"

	SilicaFlickable {
		anchors.fill: parent

		PullDownMenu {
			MenuItem {
				text: qsTr("Source")
				onClicked: quality = "source"
			}

			MenuItem {
				text: qsTr("High")
				onClicked: quality = "high"
			}

			MenuItem {
				text: qsTr("Medium")
				onClicked: quality = "medium"
			}

			MenuItem {
				text: qsTr("Low")
				onClicked: quality = "low"
			}

			MenuItem {
				text: qsTr("Mobile")
				onClicked: quality = "mobile"
			}
		}

		Video {
			id: video
			anchors.fill: parent
			autoPlay: true
			source: url[quality]
			MouseArea {
				anchors.fill: parent
				onClicked: {
					console.log("starting")
					video.play()
				}
			}
		}
	}

	function searchURL(s, q) {
		for (var x in s) {
			if (s[x].substring(0,4) === "http" && s[x].indexOf(q) >= 0)
				return s[x]
		}
	}

	Component.onCompleted: {
		HTTP.getRequest("http://api.twitch.tv/api/channels/" + channel + "/access_token", function (tokendata) {
			if (tokendata) {
				var token = JSON.parse(tokendata)
				HTTP.getRequest(encodeURI("http://usher.twitch.tv/api/channel/hls/" + channel + ".json?allow_source=true&sig=" + token.sig + "&token=" + token.token + "&type=any"), function (data) {
					if (data) {
						var video = data.split('\n')
						url = {
							source: searchURL(video, "chunked"),
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

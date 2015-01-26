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

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import org.nemomobile.configuration 1.0
import harbour.twitchtube.ircchat 1.0
import "scripts/httphelper.js" as HTTP
import "scripts/chathelper.js" as CH

Page {
	id: page
	allowedOrientations: Orientation.All

	property var url
	property string channel
	property string username
	property bool followed
	property string quality: "medium"

	ConfigurationValue {
		id: authToken
		key: "/apps/twitch/settings/oauthtoken"
		defaultValue: ""
	}

	SilicaFlickable {
		id: main
		anchors.fill: parent
		contentHeight: isPortrait ? height : height + Screen.width

		PullDownMenu {
			MenuItem {
				text: qsTr("Follow")
				onClicked: HTTP.putRequest("https://api.twitch.tv/kraken/users/" + username + "/follows/channels/" + channel + "?oauth_token=" + authToken.value, function(data) {
					if(data)
						followed = true
				})
				visible: authToken.value && !followed
			}

			MenuItem {
				text: qsTr("Unfollow")
				onClicked: HTTP.deleteRequest("https://api.twitch.tv/kraken/users/" + username + "/follows/channels/" + channel + "?oauth_token=" + authToken.value, function(data) {
					if(data === 204)
						followed = false
				})
				visible: authToken.value && followed
			}

//			MenuItem {
//				text: qsTr("Source")
//				onClicked: quality = "source"
//			}

//			MenuItem {
//				text: qsTr("High")
//				onClicked: quality = "high"
//			}

//			MenuItem {
//				text: qsTr("Medium")
//				onClicked: quality = "medium"
//			}

//			MenuItem {
//				text: qsTr("Low")
//				onClicked: quality = "low"
//			}

//			MenuItem {
//				text: qsTr("Mobile")
//				onClicked: quality = "mobile"
//			}
		}

		Video {
			id: video
			anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
			height: isPortrait ? screen.width * 9/16 : screen.width
			autoPlay: true
			source: url[quality]
			MouseArea {
				anchors.fill: parent
				onClicked: {
					console.log("video height: ", video.height)
					console.log("starting")
					video.play()
				}
			}
		}

		TextField {
			id: chatMessage
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.top: video.bottom
			placeholderText: qsTr("Chat here")
			label: qsTr("Message to send")
			EnterKey.iconSource: "image://theme/icon-m-enter-accept"
			EnterKey.enabled: text.length > 0 && authToken.value !== ""
			EnterKey.onClicked: {
				twitchChat.sendMessage(text)
				CH.parseEmoticons(username, text)
				text = ""
			}
		}

		SilicaListView {
			id: chat
			anchors.left: parent.left
			anchors.right: parent.right;
			anchors.top: chatMessage.bottom
			anchors.bottom: parent.bottom
			anchors.margins: Theme.paddingMedium
			model: ListModel { id: messages }
			delegate: Item {
				height: lbl.height
				Label {
					id: lbl
					width: chat.width
					text: (nick ? (badges.replace(new RegExp("<img", 'g'), "<img heiht=" + lbl.font.pixelSize + " width=" + lbl.font.pixelSize) +
						  "<font color=" + nick_color + ">" + nick + "</font>: ") : "") +
						  message.replace(new RegExp("<img", 'g'), "<img heiht=" + lbl.font.pixelSize + " width=" + lbl.font.pixelSize)
					textFormat: Text.RichText
					wrapMode: Text.WordWrap
				}
			}

			IrcChat {
				id: twitchChat
				pass: 'oauth:' + authToken.value
				onMessageReceived: {
					console.log("message from: ", sndnick)
					console.log("message: ", msg)
					if(sndnick)
						CH.parseEmoticons(sndnick, msg)
					else
						messages.insert(0, {message: msg})
				}
				onColorReceived: {
					CH.setColor(nick, color)
				}
				onSpecReceived: {
					console.log("spec: ", type)
					CH.addSpec(nick, type)
				}
				onSpecRemoved: {
					CH.rmSpec(nick, type)
				}

				onErrorOccured: console.log("Socket error: ", errorDescription)

				Component.onCompleted: {
					if(authToken.value === "")
						messages.insert(0, { message: "You need to login to be able to use chat." })
				}
			}

			VerticalScrollDecorator { flickable: chat }
		}
	}

	function searchURL(s, q) {
		for (var x in s) {
			if (s[x].substring(0,4) === "http" && s[x].indexOf(q) >= 0)
				return s[x]
		}
	}

	Component.onCompleted: {
		messages.append({ badges: "", nick: "aldrog", nick_color: "blue", message: "Hello, early tester!"})
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

		if(authToken.value !== "") {
			HTTP.getRequest("https://api.twitch.tv/kraken/user?oauth_token=" + authToken.value, function(data) {
				var user = JSON.parse(data)
				username = user.name
				twitchChat.name = user.name
				CH.init()

				HTTP.getRequest("https://api.twitch.tv/kraken/users/" + username + "/follows/channels/" + channel, function(data) {
					if(data)
						followed = true
					else
						followed = false
				})
			})
		}
	}
}

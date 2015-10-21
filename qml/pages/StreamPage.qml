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

import QtQuick 2.1
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import harbour.twitchtube.ircchat 1.0
import "../js/httphelper.js" as HTTP

Page {
	id: page
	allowedOrientations: Orientation.All

	property var url
	property string channel
	property string username
	property bool followed
	property bool showStream: true
	property bool active: Qt.application.active
	property bool fullscreenConditions: isLandscape && main.visibleArea.yPosition === 0 && !main.moving && !state

	states: State {
		name: "fullscreen"
		PropertyChanges {
			target: main
			contentHeight: page.height
		}

		PropertyChanges {
			target: chatMessage
			visible: false
		}

		PropertyChanges {
			target: chat
			visible: false
		}

		PropertyChanges {
			target: streamMenu
			visible: false
			active: false
		}

		PropertyChanges {
			target: page
			showNavigationIndicator: false; backNavigation: false
			allowedOrientations: Orientation.Landscape | Orientation.LandscapeInverted
		}
	}

	Timer {
		id: fullscreenTimer
		interval: 3000
		running: fullscreenConditions
		onTriggered: page.state = "fullscreen"
	}

	onStatusChanged: {
		if(status === PageStatus.Activating) {
			mainWindow.currentChannel = channel
			mainWindow.cover = Qt.resolvedUrl("../cover/StreamCover.qml")
			cpptools.setBlankingMode(false)
		}
		if(status === PageStatus.Deactivating) {
			if (_navigation === PageNavigation.Back) {
				mainWindow.cover = Qt.resolvedUrl("../cover/NavigationCover.qml")
			}
			cpptools.setBlankingMode(true)
		}
	}

	onActiveChanged: {
		if(page.status === PageStatus.Active) {
			if(active) {
				video.play()
				if(!twitchChat.connected) {
					twitchChat.reopenSocket()
					twitchChat.join(channel)
				}
			}
			else {
				video.pause()
				if(twitchChat.connected)
					twitchChat.disconnect()
			}
		}
	}

	Component.onCompleted: {
		HTTP.getRequest("http://api.twitch.tv/api/channels/" + channel + "/access_token", function (tokendata) {
			if (tokendata) {
				var token = JSON.parse(tokendata)
				HTTP.getRequest(encodeURI("http://usher.twitch.tv/api/channel/hls/" + channel + ".json?allow_source=true&sig=" + token.sig + "&token=" + token.token + "&type=any"), function (data) {
					if (data) {
						var videourls = data.split('\n')
						url = {
							chunked: searchURL(videourls, "chunked"),
							high: searchURL(videourls, "high"),
							medium: searchURL(videourls, "medium"),
							low: searchURL(videourls, "low"),
							mobile: searchURL(videourls, "mobile")
						}
						video.play()
					}
				})
			}
		})

		if(mainWindow.username) {
			HTTP.getRequest("https://api.twitch.tv/kraken/users/" + mainWindow.username + "/follows/channels/" + channel, function(data) {
				if(data)
					followed = true
				else
					followed = false
			})
		}
	}

	SilicaFlickable {
		id: main
		anchors.fill: parent
		contentHeight: isPortrait ? height : height + Screen.width

		PullDownMenu {
			id: streamMenu
			MenuItem {
				text: qsTr("Follow")
				onClicked: HTTP.putRequest("https://api.twitch.tv/kraken/users/" + username + "/follows/channels/" + channel + "?oauth_token=" + authToken.value, function(data) {
					if(data)
						followed = true
				})
				visible: mainWindow.username && !followed
			}

			MenuItem {
				text: qsTr("Unfollow")
				onClicked: HTTP.deleteRequest("https://api.twitch.tv/kraken/users/" + username + "/follows/channels/" + channel + "?oauth_token=" + authToken.value, function(data) {
					if(data === 204)
						followed = false
				})
				visible: mainWindow.username && followed
			}

			MenuItem {
				text: qsTr("Quality")
				onClicked: {
					var dialog = pageStack.push(Qt.resolvedUrl("QualityChooserPage.qml"), { chatOnly: !showStream, channel: channel })
					dialog.accepted.connect(function() {
						showStream = !dialog.chatOnly
						if(showStream && video.playbackState !== MediaPlayer.PlayingState)
							video.play()
						if(!showStream && video.playbackState !== MediaPlayer.StoppedState)
							video.stop()
					})
				}
			}
		}

		Rectangle {
			id: videoBackground
			color: "black"
			anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
			height: showStream ? (isPortrait ? screen.width * 9/16 : screen.width) : 0
			visible: showStream

			Video {
				id: video
				anchors.fill: parent
				source: url[streamQuality.value]

				BusyIndicator {
					anchors.centerIn: parent
					running: video.playbackState !== MediaPlayer.PlayingState
					size: isPortrait ? BusyIndicatorSize.Medium : BusyIndicatorSize.Large
				}

				onErrorChanged: console.error("video error:", errorString)

				MouseArea {
					anchors.fill: parent
					onClicked: {
						page.state = !page.state ? "fullscreen" : ""
						console.log(page.state)
					}
				}
			}
		}

		TextField {
			id: chatMessage
			anchors {
				left: parent.left
				right: parent.right
				top: chatFlowBtT.value ? videoBackground.bottom : undefined
				bottom: chatFlowBtT.value ? undefined : parent.bottom
				topMargin: showStream ? Theme.paddingMedium : Theme.paddingLarge
				bottomMargin: Theme.paddingMedium
			}
			// Maybe it's better to replace ternary operators with if else blocks
			placeholderText: twitchChat.connected ? (twitchChat.anonymous ? qsTr("Please log in to send messages") : qsTr("Type your message here")) : qsTr("Chat is not available")
			label: twitchChat.connected ? (twitchChat.anonymous ? qsTr("Please log in to send messages") : qsTr("Type your message here")) : qsTr("Chat is not available")
			EnterKey.iconSource: "image://theme/icon-m-enter-accept"
			EnterKey.enabled: text.length > 0 && twitchChat.connected && !twitchChat.anonymous
			EnterKey.onClicked: {
				twitchChat.sendMessage(text)
				text = ""
			}
		}

		SilicaListView {
			id: chat
			anchors {
				left: parent.left
				right: parent.right
				top: chatFlowBtT.value ? chatMessage.bottom : videoBackground.bottom
				bottom: chatFlowBtT.value ? parent.bottom : chatMessage.top
				topMargin: (!showStream && !chatFlowBtT.value) ? Theme.paddingLarge : Theme.paddingMedium//chatFlowBtT.value ? Theme.paddingSmall : Theme.paddingMedium
				bottomMargin: chatFlowBtT.value ? Theme.paddingLarge : Theme.paddingMedium
			}

			ViewPlaceholder {
				id: chatPlaceholder
				text: twitchChat.connected ? qsTr("Welcome to the chat room") : qsTr("Connecting to chat...")
				enabled: chat.model.length <= 0
				verticalOffset: -(chat.verticalLayoutDirection == ListView.TopToBottom ? (page.height - chat.height) / 2 : page.height - (page.height - chat.height) / 2)
			}

			onCountChanged: {
				if(currentIndex >= count - 2)
					currentIndex = count - 1
			}

			highlightRangeMode: ListView.StrictlyEnforceRange
			preferredHighlightBegin: chat.height
			preferredHighlightEnd: chat.height

			clip: true
			verticalLayoutDirection: chatFlowBtT.value ? ListView.BottomToTop : ListView.TopToBottom
			model: twitchChat.messages
			delegate: Item {
				height: lbl.height
				width: chat.width
				Label {
					id: lbl
					anchors {
						left: parent.left
						right: parent.right
						leftMargin: Theme.horizontalPageMargin
						rightMargin: Theme.horizontalPageMargin
					}

					text: richTextMessage
					textFormat: Text.RichText
					wrapMode: Text.WordWrap
					color: isNotice ? Theme.highlightColor : Theme.primaryColor
				}
			}

			IrcChat {
				id: twitchChat
				name: mainWindow.username
				password: 'oauth:' + authToken.value
				anonymous: !mainWindow.username
				textSize: Theme.fontSizeMedium

				Component.onCompleted: {
					twitchChat.join(channel)
				}

				onErrorOccured: {
					console.log("Chat error: ", errorDescription)
				}

				onConnectedChanged: {
					console.log(connected)
					if(!twitchChat.connected)
						reconnect.execute(remorseContainer, qsTr("Chat error, reconnecting"), function() { reopenSocket(); join(channel) })
					else
						reconnect.cancel()
				}
			}

			Rectangle {
				id: remorseContainer
				anchors.top: parent.top
				width: parent.width
				height: Theme.itemSizeMedium
				color: "transparent"
				RemorseItem { id: reconnect; onTriggered: console.log(twitchChat.connected) }
			}

			VerticalScrollDecorator { flickable: chat }
		}
		//VerticalScrollDecorator { flickable: main }
	}

	function searchURL(s, q) {
		for (var x in s) {
			if (s[x].substring(0,4) === "http" && s[x].indexOf(q) >= 0)
				return s[x]
		}
	}
}

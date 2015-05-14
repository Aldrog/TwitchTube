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

import QtQuick 2.2
import Sailfish.Silica 1.0
import "../js/httphelper.js" as HTTP

Dialog {
	id: page
	allowedOrientations: Orientation.All

	property var imageSizes: ["large", "medium", "small"]
	property string name
	// Status for NavigationCover
	property string navStatus: qsTr("Settings")

	property string authToken: qmlSettings.value("User/OAuth2Token", "", qmlSettings.change)
	property string gameImageSize: qmlSettings.value("Interface/GameImageSize", "large", qmlSettings.change)
	property string channelImageSize: qmlSettings.value("Interface/ChannelImageSize", "medium", qmlSettings.change)
	property bool showBroadcastTitles: parseInt(qmlSettings.value("Interface/ShowBroadcastTitles", 1, qmlSettings.change))
	property bool chatFlowTtB: parseInt(qmlSettings.value("Interface/ChatFlowTopToBottom", 0, qmlSettings.change))

	SilicaFlickable {
		anchors.fill: parent
		// Should look into a proper solution later
		contentHeight: header.height + login.height + gameQ.height + previewQ.height + streamTitles.height + chatTtB.height

		Column {
			id: settingsContainer
			anchors.fill: parent

			DialogHeader {
				id: header
				dialog: page

				title: qsTr("TwitchTube Settings")
				acceptText: qsTr("Apply")
				cancelText: qsTr("Cancel")
			}

			BackgroundItem {
				id: login
				width: parent.width
				height: lblAcc1.height + lblAcc2.height + 2*Theme.paddingLarge + Theme.paddingSmall

				Label {
					id: lblAcc1
					anchors {	top: parent.top
								left: parent.left
								right: parent.right
								margins: Theme.paddingLarge
							}
					text: !authToken ? qsTr("Not logged in") : (qsTr("Logged in as ") + name)
					color: login.highlighted ? Theme.highlightColor : Theme.primaryColor
					font.pixelSize: Theme.fontSizeMedium
				}

				Label {
					id: lblAcc2
					anchors {	bottom: parent.bottom
								left: parent.left
								right: parent.right
								margins: Theme.paddingLarge
							}
					text: !authToken ? qsTr("Log in") : qsTr("Log out")
					color: login.highlighted ? Theme.highlightColor : Theme.secondaryColor
					font.pixelSize: Theme.fontSizeSmall
				}

				onClicked: {
					console.log("old token:", authToken)
					if(!authToken) {
						var lpage = pageStack.push(Qt.resolvedUrl("LoginPage.qml"))
						lpage.statusChanged.connect(function() {
							if(lpage.status === PageStatus.Deactivating) {
								console.log(authToken)
								getName()
							}
						})
					}
					else {
						qmlSettings.setValue("User/OAuth2Token", "")
						console.log("Cookie cleaning script result code:", cpptools.clearCookies())
					}
				}
			}

			ComboBox {
				id: gameQ
				label: qsTr("Game posters quality")
				menu: ContextMenu {
					MenuItem { text: qsTr("High") }
					MenuItem { text: qsTr("Medium") }
					MenuItem { text: qsTr("Low") }
				}
				currentIndex: imageSizes.indexOf(gameImageSize)
			}

			ComboBox {
				id: previewQ
				label: qsTr("Stream previews quality")
				menu: ContextMenu {
					MenuItem { text: qsTr("High") }
					MenuItem { text: qsTr("Medium") }
					MenuItem { text: qsTr("Low") }
				}
				currentIndex: imageSizes.indexOf(channelImageSize)
			}

			TextSwitch {
				id: streamTitles
				text: qsTr("Show broadcast titles")
				checked: showBroadcastTitles
			}

			TextSwitch {
				id: chatTtB
				text: qsTr("Chat flows from top to bottom")
				checked: chatFlowTtB
			}
		}

		VerticalScrollDecorator { flickable: parent }
	}

	function getName() {
		HTTP.getRequest("https://api.twitch.tv/kraken/user?oauth_token=" + authToken, function(data) {
			var user = JSON.parse(data)
			name = user.display_name
		})
	}

	Component.onCompleted: {
		if(authToken)
			getName()
	}

	onAccepted: {
		qmlSettings.setValue("Interface/GameImageSize", imageSizes[gameQ.currentIndex])
		qmlSettings.setValue("Interface/ChannelImageSize", imageSizes[previewQ.currentIndex])
		qmlSettings.setValue("Interface/ShowBroadcastTitles", ~~streamTitles.checked)
		qmlSettings.setValue("Interface/ChatFlowTopToBottom", ~~chatTtB.checked)
	}
}

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
import org.nemomobile.configuration 1.0
import "scripts/httphelper.js" as HTTP

Dialog {
	id: page
	allowedOrientations: Orientation.All

	property var imageSizes: ["large", "medium", "small"]
	property string name: ""

	ConfigurationValue {
		id: authToken
		key: "/apps/twitch/settings/oauthtoken"
		defaultValue: ""
	}

	ConfigurationValue {
		id: gameImageSize
		key: "/apps/twitch/settings/gameimgsize"
		defaultValue: "large"
	}

	ConfigurationValue {
		id: previewImageSize
		key: "/apps/twitch/settings/previewimgsize"
		defaultValue: "medium"
	}

	Column {
		id: settings
		anchors.fill: parent

		DialogHeader {
			title: qsTr("Twitch Settings")
			acceptText: qsTr("Apply")
			cancelText: qsTr("Cancel")
		}

		BackgroundItem {
			id: login
			width: parent.width
			Label {
				anchors.fill: parent
				anchors.margins: Theme.paddingLarge
				text: authToken.value === "" ? qsTr("Log in") : qsTr("Log out")
				color: login.highlighted ? Theme.highlightColor : Theme.primaryColor
			}
			onClicked: {
				console.log("old token: ", authToken.value)
				if(authToken.value === "")
					pageStack.push(Qt.resolvedUrl("LoginPage.qml"))
				else
					authToken.value = ""
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
			currentIndex: imageSizes.indexOf(gameImageSize.value)
		}

		ComboBox {
			id: previewQ
			label: qsTr("Stream previews quality")
			menu: ContextMenu {
				MenuItem { text: qsTr("High") }
				MenuItem { text: qsTr("Medium") }
				MenuItem { text: qsTr("Low") }
			}
			currentIndex: imageSizes.indexOf(previewImageSize.value)
		}
		//Uncomment this when there will be more settings
		//VerticalScrollDecorator { flickable: settings }
	}

	Component.onCompleted: {
		HTTP.getRequest("https://api.twitch.tv/kraken/user?oauth_token=" + authToken.value, function(data) {
			var user = JSON.parse(data)
			name = user.display_name
		})
	}

	onAccepted: {
		gameImageSize.value = imageSizes[gameQ.currentIndex]
		previewImageSize.value = imageSizes[previewQ.currentIndex]
	}
}

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

Page {
	id: page
	allowedOrientations: Orientation.All

	property bool needExit: false
	// Status for NavigationCover
	property string navStatus: qsTr("Settings")

	PageHeader {
		id: head
		title: qsTr("Log into Twitch account")
	}

	SilicaWebView {
		id: twitchLogin
		anchors {
			top: head.bottom
			bottom: parent.bottom
			left: parent.left
			right: parent.right
		}
		onNavigationRequested: {
			console.log(request.url)
			var url = request.url.toString()
			if(url.indexOf("http://localhost") === 0) {
				var params = url.substring(url.lastIndexOf('/') + 1)
				if(params.indexOf("#access_token") >= 0) {
					qmlSettings.setValue("User/OAuth2Token", params.split('=')[1].split('&')[0])
				}
				if(status === PageStatus.Activating)
					needExit = true
				else
					pageStack.pop()
			}
			else
				request.action = SilicaWebView.AcceptRequest;
		}
		url: encodeURI("https://api.twitch.tv/kraken/oauth2/authorize?response_type=token&client_id=n57dx0ypqy48ogn1ac08buvoe13bnsu&redirect_uri=http://localhost&scope=user_read user_follows_edit chat_login")
	}

	onStatusChanged: if(status === PageStatus.Active && needExit) pageStack.pop()
}

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

Page {
	id: page
	allowedOrientations: Orientation.All

	ConfigurationValue {
		id: authToken
		key: "/apps/twitch/settings/oauthtoken"
		defaultValue: ""
	}

	PageHeader {
		id: head
		title: qsTr("Log into your Twitch account")
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
			console.log(request.url.toString().split('#')[1])
			if(request.url.toString().split('#')[0] === "http://localhost/") {
				authToken.value = request.url.toString().split('=')[1].split('&')[0]
				console.log(authToken.value)
				navigateBack()
			}
			else
				request.action = SilicaWebView.AcceptRequest;
		}
		url: encodeURI("https://api.twitch.tv/kraken/oauth2/authorize?response_type=token&client_id=n57dx0ypqy48ogn1ac08buvoe13bnsu&redirect_uri=http://localhost&scope=user_read user_follows_edit chat_login")
	}
}

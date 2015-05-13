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
import QtGraphicalEffects 1.0
import "elements"
import "../js/httphelper.js" as HTTP

Page {
	id: page
	allowedOrientations: Orientation.All

	property string game
	property string username
	property bool followed
	property bool fromFollowings: false
	// Status for NavigationCover
	property string navStatus: game

	property string authToken: qmlSettings.value("User/OAuth2Token", "", qmlSettings.change)

	ChannelsGrid {
		id: gridChannels

		function loadChannels() {
			var url = "https://api.twitch.tv/kraken/streams?limit=" + countOnPage + "&offset=" + offset + encodeURI("&game=" + game)
			HTTP.getRequest(url,function(data) {
				if (data) {
					offset += countOnPage
					var result = JSON.parse(data)
					totalCount = result._total
					for (var i in result.streams)
						model.append(result.streams[i])
				}
			})
		}

		Categories {
			games: fromFollowings
			following: !fromFollowings && authToken
		}

		header: PageHeader {
			id: header
			title: (authToken ? "\t\t " : "") + game
			BackgroundItem {
				id: follow
				parent: header.extraContent
				visible: authToken
				anchors.verticalCenter: parent.verticalCenter
				anchors.left: parent.left
				anchors.leftMargin: 50
				height: Theme.itemSizeSmall - (isPortrait ? 0 : Theme.paddingSmall)
				width: height

				Image {
					id: heart
					anchors.fill: parent
					source: "../images/heart.png"
					visible: false
				}
				ColorOverlay {
					id: heartEffect1
					anchors.fill: heart
					source: heart
					visible: false
					color: follow.highlighted ? Theme.highlightColor : Theme.primaryColor
				}
				DropShadow {
					id: heartEffect2
					anchors.fill: heartEffect1
					source: heartEffect1
					horizontalOffset: 3
					verticalOffset: 3
					radius: 8.0
					samples: 16
					color: "#80000000"
				}

				Image {
					id: cross
					anchors.fill: parent
					source: "../images/cross.png"
					z: 1
					visible: false
				}
				ColorOverlay {
					id: crossEffect1
					anchors.fill: cross
					source: cross
					visible: false
					color: follow.highlighted ? Theme.highlightColor : Theme.primaryColor
				}
				DropShadow {
					id: crossEffect2
					anchors.fill: crossEffect1
					source: crossEffect1
					horizontalOffset: 3
					verticalOffset: 3
					radius: 8.0
					samples: 16
					color: "#80000000"
					visible: followed
				}

				onClicked: {
					if(!followed)
						HTTP.putRequest("https://api.twitch.tv/api/users/" + username + "/follows/games/" + game + "?oauth_token=" + authToken, function(data) {
							if(data)
								followed = true
						})
					else
						HTTP.deleteRequest("https://api.twitch.tv/api/users/" + username + "/follows/games/" + game + "?oauth_token=" + authToken, function(data) {
							if(data === 204)
								followed = false
						})
				}
			}
		}
	}

	Component.onCompleted: {
		if(authToken) {
			HTTP.getRequest("https://api.twitch.tv/kraken/user?oauth_token=" + authToken, function(data) {
				var user = JSON.parse(data)
				username = user.name
				HTTP.getRequest("https://api.twitch.tv/api/users/" + username + "/follows/games/" + game, function(data) {
					if(data)
						followed = true
					else
						followed = false
				})
			})
		}
	}
}

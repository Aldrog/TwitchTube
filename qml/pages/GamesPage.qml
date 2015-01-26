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
import "elements"
import "scripts/httphelper.js" as HTTP

Page {
	id: page
	allowedOrientations: Orientation.All

	property int row: isPortrait ? 2 : 4
	// In brackets should be row lengths for portrait and landscape orientations
	property int countOnPage: (2*4)*2
	property string nextlink

	ConfigurationValue {
		id: posterSize
		key: "/apps/twitch/settings/gameimgsize"
		defaultValue: "medium"
	}

	ConfigurationValue {
		id: authToken
		key: "/apps/twitch/settings/oauthtoken"
		defaultValue: ""
	}

	SilicaGridView {
		id: gridGames
		anchors.fill: parent

		Categories {
			games: false
			following: authToken.value !== ""
		}

		PushUpMenu {
			MenuItem {
				text: qsTr("Load more")
				onClicked: {
					HTTP.getRequest(nextlink,function(data) {
						if (data) {
							var result = JSON.parse(data)
							nextlink = result._links.next
							for (var i in result.top)
								gameList.append(result.top[i])
						}
					})
				}
			}
		}

		header: PageHeader {
			title: qsTr("Popular Games")
		}

		model: ListModel { id: gameList }
		cellWidth: width/row
		cellHeight: cellWidth*18/13

		delegate: BackgroundItem {
			id: delegate
			width: gridGames.cellWidth
			height: gridGames.cellHeight
			onClicked: pageStack.push (Qt.resolvedUrl("ChannelsPage.qml"),{ bygame: true, game: game.name })

			Image {
				id: logo
				fillMode: Image.PreserveAspectCrop
				source: game.box[posterSize.value]
				anchors {
					fill: parent
					leftMargin: Theme.paddingSmall
					rightMargin: Theme.paddingSmall
					topMargin: Theme.paddingSmall
					bottomMargin: Theme.paddingSmall
				}
				visible: false
			}

			ShaderEffect {
				anchors.fill: logo
				property variant src: logo
				property real h: 2 * name.height/height
				vertexShader: "
					uniform highp mat4 qt_Matrix;
					attribute highp vec4 qt_Vertex;
					attribute highp vec2 qt_MultiTexCoord0;
					varying highp vec2 coord;
					void main() {
						coord = qt_MultiTexCoord0;
						gl_Position = qt_Matrix * qt_Vertex;
					}"
				fragmentShader: "
					varying highp vec2 coord;
					uniform sampler2D src;
					uniform lowp float h;
					uniform lowp float qt_Opacity;
					void main() {
						lowp vec4 tex = texture2D(src, coord);
						if(coord.y <= h)
							tex = vec4((tex.rgb)*(coord.y/(h)), coord.y/(h));
						gl_FragColor = tex * qt_Opacity;
					}"
			}

			Label {
				id: name
				anchors {
					left: parent.left; leftMargin: Theme.paddingLarge
					right: parent.right; rightMargin: Theme.paddingLarge
					topMargin: Theme.paddingMedium
				}
				text: game.name
				truncationMode: TruncationMode.Fade
				color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
				font.pixelSize: Theme.fontSizeSmall
			}
        }

		VerticalScrollDecorator { flickable: gridGames }
    }

	Component.onCompleted: {
		HTTP.getRequest("https://api.twitch.tv/kraken/games/top?limit="+countOnPage, function (data) {
			if (data) {
				var result = JSON.parse(data)
				nextlink = result._links.next
				for (var i in result.top)
					gameList.append(result.top[i])
			}
		})
	}
}



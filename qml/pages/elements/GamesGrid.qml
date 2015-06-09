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

SilicaGridView {
	id: root
	anchors.fill: parent
	property int row: isPortrait ? 2 : 4
	// In brackets must be row lengths for portrait and landscape orientations
	property int countOnPage: (2*4) * 2
	property int offset: 0
	property int totalCount: 0
	property bool autoLoad: true
	property var parameters: ({})

	PushUpMenu {
		enabled: offset < totalCount
		visible: offset < totalCount

		MenuItem {
			text: qsTr("Load more")
			onClicked: {
				loadGames()
			}
		}
	}

	ViewPlaceholder {
		enabled: model.count <= 0
		text: qsTr("No games to show")
	}

	model: ListModel { id: gameList }
	cellWidth: width/row
	// 18:13 is the actual aspect ratio of previews
	cellHeight: cellWidth * 18/13

	delegate: BackgroundItem {
		id: delegate
		width: root.cellWidth
		height: root.cellHeight
		onClicked: {
			var properties = parameters
			properties.game = name
			pageStack.push (Qt.resolvedUrl("../GameChannelsPage.qml"), properties)
		}

		Image {
			id: logo
			anchors.fill: parent
			anchors.margins: Theme.paddingSmall
			fillMode: Image.PreserveAspectCrop
			source: box[gameImageSize.value]
		}

		OpacityRampEffect {
			sourceItem: logo
			direction: OpacityRamp.BottomToTop
			offset: 1 - 1.25 * (gameName.height / logo.height)
			slope: logo.height / gameName.height
		}

		Label {
			id: gameName
			anchors {
				left: parent.left; leftMargin: Theme.paddingLarge
				right: parent.right; rightMargin: Theme.paddingLarge
				topMargin: Theme.paddingMedium
			}
			text: name
			truncationMode: TruncationMode.Fade
			color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
			font.pixelSize: Theme.fontSizeSmall
		}
	}

	VerticalScrollDecorator { flickable: root }

	Component.onCompleted: {
		if(autoLoad)
			loadGames()
	}
}

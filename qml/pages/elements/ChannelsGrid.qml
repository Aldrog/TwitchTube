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

SilicaGridView {
	id: root
	anchors.fill: parent
	property int row: isPortrait ? 2 : 3
	// In brackets must be row lengths for portrait and landscape orientations
	property int countOnPage: (2*3) * 3
	property int offset: 0
	property int totalCount: 0
	property bool autoLoad: true
	property var parameters: ({})

	property string channelImageSize: qmlSettings.value("Interface/ChannelImageSize", "medium", qmlSettings.change)
	property bool showBroadcastTitles: parseInt(qmlSettings.value("Interface/ShowBroadcastTitles", 1, qmlSettings.change))

	PushUpMenu {
		enabled: offset < totalCount
		visible: offset < totalCount

		MenuItem {
			text: qsTr("Load more")
			onClicked: {
				loadChannels()
			}
		}
	}

	ViewPlaceholder {
		enabled: model.count <= 0
		text: qsTr("No channels to show")
	}

	model: ListModel { id: channelsList }
	cellWidth: width/row
	// 5:8 is the actual aspect ratio of previews
	cellHeight: cellWidth * 5/8

	delegate: BackgroundItem {
		id: delegate
		width: root.cellWidth
		height: root.cellHeight
		onClicked: {
			var properties = parameters
			properties.channel = channel.name
			pageStack.push (Qt.resolvedUrl("../StreamPage.qml"), properties)
		}

		Image {
			id: previewImage
			source: preview[channelImageSize]
			anchors.fill: parent
			anchors.margins: Theme.paddingSmall
		}

		OpacityRampEffect {
			property real effHeight: (showBroadcastTitles && title.text) ? (title.height + title.y) : name.height
			sourceItem: previewImage
			direction: OpacityRamp.BottomToTop
			offset: 1 - 1.25 * (effHeight / previewImage.height)
			slope: previewImage.height / effHeight
		}

		Label {
			id: name
			anchors {
				left: previewImage.left; leftMargin: Theme.paddingMedium
				right: previewImage.right; rightMargin: Theme.paddingSmall
				topMargin: Theme.paddingSmall
			}
			text: channel.display_name
			truncationMode: TruncationMode.Fade
			color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
			font.pixelSize: Theme.fontSizeSmall
		}

		Label {
			id: title
			visible: showBroadcastTitles
			anchors {
				left: previewImage.left; leftMargin: Theme.paddingMedium
				right: previewImage.right; rightMargin: Theme.paddingSmall
				top: name.bottom; topMargin: -Theme.paddingSmall
			}
			text: channel.status
			truncationMode: TruncationMode.Fade
			color: delegate.highlighted ? Theme.highlightColor : Theme.secondaryColor
			font.pixelSize: Theme.fontSizeSmall
		}
	}

	VerticalScrollDecorator { flickable: root }

	Component.onCompleted: {
		if(autoLoad)
			loadChannels()
	}
}

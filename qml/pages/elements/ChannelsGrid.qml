/*
 * Copyright © 2015-2016 Andrew Penkrat
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
    id: grid

    property alias channels: grid.model
    property bool loadMoreAvailable: offset < totalCount
    property int row: isPortrait ? 2 : 3
    // In brackets must be row lengths for portrait and landscape orientations
    property int countOnPage: (2*3) * 3
    property int offset: 0
    property int totalCount: 0
    property bool autoLoad: true
    property var parameters: ({})

    height: childrenRect.height

    Component.onCompleted: {
        if(autoLoad)
            loadContent()
    }

    anchors {
        left: parent.left
        right: parent.right
    }
    interactive: false

    model: ListModel { id: channelsList }
    cellWidth: width/row
    // 1:1 is the actual aspect ratio of logos
    cellHeight: cellWidth * 1/1

    delegate: BackgroundItem {
        id: delegate

        width: grid.cellWidth
        height: grid.cellHeight

        onClicked: {
            var properties = parameters
            properties.channel = channel.name
            properties.display = channel.display_name
            pageStack.push (Qt.resolvedUrl("../ChannelPage.qml"), properties)
        }

        Image {
            id: logoImage

            source: channel.logo
            anchors.fill: parent
            anchors.margins: Theme.paddingSmall
        }

        OpacityRampEffect {
            property real effHeight: name.height
            sourceItem: logoImage
            direction: OpacityRamp.BottomToTop
            offset: 1 - 1.25 * (effHeight / logoImage.height)
            slope: logoImage.height / effHeight
        }

        Label {
            id: name

            anchors {
                left: logoImage.left; leftMargin: Theme.paddingMedium
                right: logoImage.right; rightMargin: Theme.paddingSmall
                topMargin: Theme.paddingSmall
            }
            text: channel.display_name
            truncationMode: TruncationMode.Fade
            color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    ViewPlaceholder {
        enabled: channels.count <= 0
        text: qsTr("No channels to show")
    }
}

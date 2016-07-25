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

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3

GridView {
    id: grid

    property alias channels: grid.model
    property bool loadMoreAvailable: offset < totalCount
    property int row: 3
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
    // 5:8 is the actual aspect ratio of previews
    cellHeight: cellWidth * 5/8

    delegate: Empty {
        id: delegate

        width: grid.cellWidth
        height: grid.cellHeight

        onClicked: {
            var properties = parameters
            properties.channel = channel.name
            pageStack.push (Qt.resolvedUrl("../StreamPage.qml"), properties)
        }

        Image {
            id: previewImage

            source: preview[channelImageSize.value]
            anchors.fill: parent
            anchors.margins: units.gu(1)
        }

        Label {
            id: name

            anchors {
                left: previewImage.left; leftMargin: units.gu(2)
                right: previewImage.right; rightMargin: units.gu(1)
                topMargin: units.gu(1)
            }
            text: channel.display_name
            color: UbuntuColors.lightGrey
        }

        Label {
            id: title

            visible: showBroadcastTitles.value
            anchors {
                left: previewImage.left; leftMargin: units.gu(2)
                right: previewImage.right; rightMargin: units.gu(1)
                top: name.bottom; topMargin: -units.gu(1)
            }
            text: channel.status
            color: UbuntuColors.silk
        }
    }
}

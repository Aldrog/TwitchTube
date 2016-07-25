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

    property alias games: grid.model
    property int row: 4
    // In brackets must be row lengths for portrait and landscape orientations
    property int countOnPage: (2*4) * 2
    property int offset: 0
    property int totalCount: 0
    property bool autoLoad: true
    property var parameters: ({})

    Component.onCompleted: {
        if(autoLoad)
            loadContent()
    }

    height: childrenRect.height
    anchors {
        left: parent.left
        right: parent.right
    }

    interactive: false

    model: ListModel { id: gameList }
    cellWidth: width/row
    // 18:13 is the actual aspect ratio of previews
    cellHeight: cellWidth * 18/13

    delegate: Empty {
        id: delegate

        width: grid.cellWidth
        height: grid.cellHeight
        onClicked: {
            var properties = parameters
            properties.game = name
            pageStack.push (Qt.resolvedUrl("../GameChannelsPage.qml"), properties)
        }

        Image {
            id: logo

            anchors.fill: parent
            anchors.margins: units.gu(1)
            fillMode: Image.PreserveAspectCrop
            source: box[gameImageSize.value]
        }

        Label {
            id: gameName

            anchors {
                left: parent.left; leftMargin: units.gu(2)
                right: parent.right; rightMargin: units.gu(2)
                topMargin: units.gu(1)
            }
            text: name
            color: UbuntuColors.silk
        }
    }
}

/*
 * Copyright © 2019 Andrew Penkrat <contact.aldrog@gmail.com>
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
 * along with TwitchTube.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.6
import Sailfish.Silica 1.0

Grid {
    id: grid

    property real dpiWidth
    readonly property int contentWidth: width - leftPadding - rightPadding
    property alias model: repeater.model
    property alias delegate: repeater.delegate
    property int cellWidth: contentWidth/columns
    property int cellHeight

    leftPadding: Theme.horizontalPageMargin - Theme.paddingSmall
    rightPadding: Theme.horizontalPageMargin - Theme.paddingSmall
    width: parent.width
    columns: Math.round(width / (Theme.pixelRatio * dpiWidth))

    Repeater {
        id: repeater
        anchors.fill: parent
        onItemAdded: {
            item.width  = Qt.binding(function() { return grid.cellWidth  })
            item.height = Qt.binding(function() { return grid.cellHeight })
        }
    }
}

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

BackgroundItem {
    property string icon
    property alias text: label.text
    property bool active: false

    height: img.height + label.height
    width: height

    Image {
        id: img
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        width: Theme.itemSizeSmall
        height: width
        source: icon + "?" + (highlighted || active
                               ? Theme.highlightColor
                               : Theme.primaryColor)
    }

    Label {
        id: label
        anchors {
            top: img.bottom
            horizontalCenter: img.horizontalCenter
        }
        color: highlighted || active ? Theme.highlightColor : Theme.primaryColor
        font.pixelSize: Theme.fontSizeExtraSmall
    }
}

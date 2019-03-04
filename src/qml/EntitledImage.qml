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
    id: item

    width: GridView.view.cellWidth
    height: GridView.view.cellHeight

    Image {
        id: img
        anchors.fill: parent
        anchors.margins: Theme.paddingSmall
        fillMode: Image.PreserveAspectCrop
        source: image
    }

    OpacityRampEffect {
        property real effHeight: name.height
        sourceItem: img
        direction: OpacityRamp.BottomToTop
        offset: 1 - 1.25 * (effHeight / img.height)
        slope: img.height / effHeight
    }

    Label {
        id: name
        anchors {
            left: img.left; leftMargin: Theme.paddingMedium
            right: img.right; rightMargin: Theme.paddingSmall
            topMargin: Theme.paddingSmall
        }
        truncationMode: TruncationMode.Fade
        color: item.highlighted ? Theme.highlightColor : Theme.primaryColor
        font.pixelSize: Theme.fontSizeSmall
        text: title
    }
}

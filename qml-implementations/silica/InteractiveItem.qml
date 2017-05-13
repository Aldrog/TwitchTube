/*
 * Copyright © 2017 Andrew Penkrat
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

BackgroundItem {
    property alias title: title.text
    property alias subtitle: subtitle.text

    height: title.height + subtitle.height + 2*Theme.paddingLarge + Theme.paddingSmall

    Label {
        id: title

        anchors { top: parent.top
                  left: parent.left
                  right: parent.right
                  topMargin: Theme.paddingLarge
                  leftMargin: Theme.horizontalPageMargin
                  rightMargin: Theme.horizontalPageMargin
                }
        color: login.highlighted ? Theme.highlightColor : Theme.primaryColor
        font.pixelSize: Theme.fontSizeMedium
    }

    Label {
        id: subtitle

        anchors { top: title.bottom //parent.bottom
                  left: parent.left
                  right: parent.right
                  topMargin: Theme.paddingSmall
                  leftMargin: Theme.horizontalPageMargin
                  rightMargin: Theme.horizontalPageMargin
                }
        color: login.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
        font.pixelSize: Theme.fontSizeSmall
    }
}

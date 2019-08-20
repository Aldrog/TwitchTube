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
import QTwitch.Models 0.1

Loader {
    id: loader

    property SilicaFlickable flickable
    property QtObject model

    active: model.nextAvailable

    width: parent.width
    height: active ? Theme.itemSizeExtraLarge : 0

    sourceComponent: Component { Item {
        property bool fresh: true
        property bool processing: false
        property bool active: !fresh && !processing
        property bool trigger: active && loader.flickable.contentY + loader.flickable.height > loader.y

        function activate() {
            model.next()
        }

        onTriggerChanged: {
            if (trigger) {
                activate()
            }
        }

        Connections {
            target: loader.flickable
            onContentHeightChanged: processing = false
        }

        Connections {
            target: loader.model
            onRowsRemoved: {
                fresh = true
            }
            onRowsInserted: {
                processing = true
                fresh = false
            }
        }

        BusyIndicator {
            running: true
            size: BusyIndicatorSize.Medium
            anchors.centerIn: parent
        }
    } }
}

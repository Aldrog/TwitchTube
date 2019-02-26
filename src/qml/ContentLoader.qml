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

Item {
    id: loader

    property SilicaFlickable flickable
    property QtObject model
    property bool trigger: flickable.contentY + flickable.height > loader.y
    signal triggered

    width: parent.width
    height: Theme.itemSizeExtraLarge

    onTriggered: {
        model.next()
        triggerTimeout.start()
    }

    onTriggerChanged: {
        if (trigger && !triggerTimeout.running) {
            triggered()
        }
    }

    Timer {
        id: triggerTimeout
        interval: 1000
        running: true
        onTriggered: {
            if (trigger)
                triggered()
        }
    }

    BusyIndicator {
        running: true
        size: BusyIndicatorSize.Medium
        anchors.centerIn: parent
    }
}

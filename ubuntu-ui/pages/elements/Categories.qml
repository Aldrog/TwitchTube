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

Item {
    property bool search: true
    property bool following: true
    property bool channels: true
    property bool games: true

    property list<Action> actions: [
        Action {
            text: qsTr("Games")
            visible: games
            onTriggered: {
                pageStack.pop()
                pageStack.push(Qt.resolvedUrl("../GamesPage.qml"))
            }
        },

        Action {
            text: qsTr("Channels")
            visible: channels
            onTriggered: {
                pageStack.pop()
                pageStack.push(Qt.resolvedUrl("../ChannelsPage.qml"))
            }
        },

        Action {
            text: qsTr("Following")
            visible: following && mainWindow.username
            onTriggered: {
                pageStack.pop()
                pageStack.push(Qt.resolvedUrl("../FollowedPage.qml"))
            }
        },

        Action {
            text: qsTr("Search")
            visible: search
            onTriggered: {
                pageStack.pop()
                pageStack.push(Qt.resolvedUrl("../SearchPage.qml"))
            }
        },

        Action {
            text: qsTr("Settings")
            onTriggered: {
                pageStack.push(Qt.resolvedUrl("../SettingsPage.qml"))
            }
        }
    ]
}

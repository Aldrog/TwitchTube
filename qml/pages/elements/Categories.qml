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

PullDownMenu {
    property bool search: true
    property bool following: true
    property bool channels: true
    property bool games: true

    MenuItem {
        text: qsTr("Settings")
        onClicked: {
            pageStack.push(Qt.resolvedUrl("../SettingsPage.qml"))
        }
    }

    MenuItem {
        text: qsTr("Search")
        onClicked: {
            mainWindow.currentCategory = "search"
            pageStack.replaceAbove(null, Qt.resolvedUrl("../SearchPage.qml"))
        }
        visible: search
    }

    MenuItem {
        text: qsTr("Following")
        onClicked: {
            mainWindow.currentCategory = "following"
            pageStack.replaceAbove(null, Qt.resolvedUrl("../FollowedPage.qml"))
        }
        visible: following && mainWindow.username
    }

    MenuItem {
        text: qsTr("Channels")
        onClicked: {
            mainWindow.currentCategory = "channels"
            pageStack.replaceAbove(null, Qt.resolvedUrl("../TopStreamsPage.qml"))
        }
        visible: channels
    }

    MenuItem {
        text: qsTr("Games")
        onClicked: {
            mainWindow.currentCategory = "games"
            pageStack.replaceAbove(null, Qt.resolvedUrl("../TopGamesPage.qml"))
        }
        visible: games
    }
}

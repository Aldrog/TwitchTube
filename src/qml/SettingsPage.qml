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
import QTwitch.Api 0.1
import QTwitch.Models 0.1

Dialog {
    id: page
    allowedOrientations: Orientation.All

    onAccepted: {
        config.showStreamTitles = streamTitles.checked
        config.connectToChat = chatConnection.checked
    }

    InterfaceConfiguration {
        id: config
        property bool showStreamTitles: true
        property bool connectToChat: true
    }

    Binding {
        target: mainWindow
        property: "showCategories"
        value: status !== PageStatus.Active && status !== PageStatus.Activating
    }

    DialogHeader {
        id: header
        title: qsTr("Settings")
        dialog: page
    }

    Column {
        id: content
        anchors.top: header.bottom
        width: parent.width

        UserInfo { id: user } // TODO: Connect to Client's userId

        ValueButton {
            id: login

            width: parent.width
            label: Client.authorizationStatus === Client.Authorized ? qsTr("Log out") : qsTr("Sign in")
            value: Client.authorizationStatus === Client.Authorized ? qsTr("Logged in as %1").arg(user.display) : qsTr("No account connected")

            onClicked: {
            }

        }

        TextSwitch {
            id: streamTitles

            text: qsTr("Show stream titles")
            checked: config.showStreamTitles
        }

        TextSwitch {
            id: chatConnection

            text: qsTr("Automatically connect to chat")
            checked: config.connectToChat
        }
    }
}

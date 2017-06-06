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
import "implementation"

Rectangle {
    id: root

    property alias chatModel: chatView.model
    property bool displayMessageField: true
    property bool connected: false

    signal messageSent(string message)

    color: "transparent"

    MessageField {
        id: chatMessage

        anchors {
            left: parent.left
            right: parent.right
            top: chatFlowBtT.value ? parent.top : undefined
            bottom: chatFlowBtT.value ? undefined : parent.bottom
            //topMargin: (chatMode || audioMode) ? Theme.paddingLarge : Theme.paddingMedium
            //bottomMargin: Theme.paddingMedium
        }
        visible: displayMessageField
        // Maybe it's better to replace ternary operators with if else blocks
        placeholderText: twitchChat.connected ? (twitchChat.anonymous ? qsTr("Please log in to send messages") : qsTr("Type your message here")) : qsTr("Chat is not available")
        label: twitchChat.connected ? (twitchChat.anonymous ? qsTr("Please log in to send messages") : qsTr("Type your message here")) : qsTr("Chat is not available")
        onAccepted: messageSent(text)
    }

    ChatView {
        id: chatView

        anchors {
            left: parent.left
            right: parent.right
            top: chatFlowBtT.value ? chatMessage.bottom : parent.top
            bottom: chatFlowBtT.value ? parent.bottom : chatMessage.top
        }
    }
}

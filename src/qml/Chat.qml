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

Rectangle {
    id: root

    property alias chatModel: chatView.model
    property bool displayMessageField: true
    property bool connected: false

    signal messageSent(string message)

    color: "transparent"

    TextField {
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
        EnterKey.iconSource: "image://theme/icon-m-enter-accept"
        EnterKey.enabled: text.length > 0 && twitchChat.connected && !twitchChat.anonymous
        EnterKey.onClicked: {
            messageSent(text)
            text = ""
        }
    }

    SilicaListView {
        id: chatView

        property bool atEnd: true

        preferredHighlightEnd: chatView.height
        clip: true
        verticalLayoutDirection: chatFlowBtT.value ? ListView.BottomToTop : ListView.TopToBottom

        onMovementStarted: {
            atEnd = false
            currentIndex = -1
        }

        onMovementEnded: {
            if(chatView.atYEnd) {
                atEnd = true
                currentIndex = count - 1
            }
        }

        // This makes sure individual messages don't get lost
        onAtYEndChanged: {
            if(atEnd && !atYEnd)
                currentIndex = chatView.count - 1
        }

        model: twitchChat.messages
        delegate: Item {
            height: lbl.height
            width: chatView.width

            property bool viewed: false

            // This is the main handler for chat autoscroll, though it only works when messages count's increased
            // above there's additional handler covering this case
            ListView.onAdd: {
                if(!viewed && chatView.atEnd) {
                    chatView.currentIndex = chatView.count - 1
                }
                viewed = true
            }

            Label {
                id: lbl

                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }

                text: richTextMessage
                textFormat: Text.RichText
                wrapMode: Text.WordWrap
                color: isNotice ? Theme.highlightColor : Theme.primaryColor
            }
        }

        ViewPlaceholder {
            id: chatPlaceholder

            text: twitchChat.connected ? qsTr("Welcome to the chat room") : qsTr("Connecting to chat...")
            enabled: chatView.count <= 0
            verticalOffset: -(chatView.verticalLayoutDirection === ListView.TopToBottom ? (page.height - chatView.height) / 2 : page.height - (page.height - chatView.height) / 2)
        }

        VerticalScrollDecorator { flickable: chatView }

        anchors {
            left: parent.left
            right: parent.right
            top: chatFlowBtT.value ? chatMessage.bottom : parent.top
            bottom: chatFlowBtT.value ? parent.bottom : chatMessage.top
        }
    }
}

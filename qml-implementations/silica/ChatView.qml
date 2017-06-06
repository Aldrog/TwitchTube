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

SilicaListView {
    id: chat

    property bool atEnd: true

    preferredHighlightEnd: chat.height
    clip: true
    verticalLayoutDirection: chatFlowBtT.value ? ListView.BottomToTop : ListView.TopToBottom

    onMovementStarted: {
        atEnd = false
        currentIndex = -1
    }

    onMovementEnded: {
        if(chat.atYEnd) {
            atEnd = true
            currentIndex = count - 1
        }
    }

    // This makes sure individual messages don't get lost
    onAtYEndChanged: {
        if(atEnd && !atYEnd)
            currentIndex = chat.count - 1
    }

    model: twitchChat.messages
    delegate: Item {
        height: lbl.height
        width: chat.width

        property bool viewed: false

        // This is the main handler for chat autoscroll, though it only works when messages count's increased
        // above there's additional handler covering this case
        ListView.onAdd: {
            if(!viewed && chat.atEnd) {
                chat.currentIndex = chat.count - 1
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
        enabled: chat.count <= 0
        verticalOffset: -(chat.verticalLayoutDirection == ListView.TopToBottom ? (page.height - chat.height) / 2 : page.height - (page.height - chat.height) / 2)
    }

    VerticalScrollDecorator { flickable: chat }
}

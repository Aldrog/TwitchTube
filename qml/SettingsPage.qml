/*
 * Copyright © 2015-2017 Andrew Penkrat
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
import "js/httphelper.js" as HTTP

Dialog {
    id: page

    property var imageSizes: ["large", "medium", "small"]
    property string name
    // Status for NavigationCover
    property string navStatus: qsTr("Settings")

    function getName() {
        HTTP.getRequest("https://api.twitch.tv/kraken/user?oauth_token=" + authToken.value, function(data) {
            var user = JSON.parse(data)
            name = user.display_name
            mainWindow.username = user.name
        })
    }

    title: qsTr("Settings")

    Component.onCompleted: {
        if(authToken.value)
            getName()
    }

    onAccepted: {
        gameImageSize.value = imageSizes[gameQ.currentIndex]
        channelImageSize.value = imageSizes[previewQ.currentIndex]
        showBroadcastTitles.value = streamTitles.checked
        chatFlowBtT.value = chatTtB.checked
    }

    InteractiveItem {
        id: login

        width: parent.width
        title:    !authToken.value ? qsTr("Log in")        : qsTr("Log out")
        subtitle: !authToken.value ? qsTr("Not logged in") : qsTr("Logged in as %1").arg(name)

        onClicked: {
            console.log("old token:", authToken.value)
            if(!authToken.value) {
                var lpage = pageStack.push(Qt.resolvedUrl("LoginPage.qml"))
                lpage.statusChanged.connect(function() {
                    if(lpage.status === PageStatus.Deactivating) {
                        getName()
                    }
                })
            } else {
                authToken.value = ""
                console.log("Cookie cleaning script result code:", cpptools.clearCookies())
                name = ""
                mainWindow.username = ""
            }
        }

    }

    TextSwitch {
        id: streamTitles

        text: qsTr("Show broadcast titles")
        checked: showBroadcastTitles.value
    }

    TextSwitch {
        id: chatTtB

        text: qsTr("Chat flows from bottom to top")
        checked: chatFlowBtT.value
    }

    ComboBox {
        id: gameQ

        label: qsTr("Game posters quality")
        optionsList: { qsTr("High"), qsTr("Medium"), qsTr("Low") }
        currentIndex: imageSizes.indexOf(gameImageSize.value)
    }

    ComboBox {
        id: previewQ

        label: qsTr("Stream previews quality")
        optionsList: { qsTr("High"), qsTr("Medium"), qsTr("Low") }
        currentIndex: imageSizes.indexOf(channelImageSize.value)
    }
}

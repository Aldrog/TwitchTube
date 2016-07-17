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
import "../js/httphelper.js" as HTTP

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

    allowedOrientations: Orientation.All

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

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: header.height + settingsContainer.height + Theme.paddingLarge // for bottom margin

        DialogHeader {
            id: header

            dialog: page
            title: qsTr("Settings")
            acceptText: qsTr("Apply")
            cancelText: qsTr("Cancel")
        }

        Column {
            id: settingsContainer

            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
            }

            BackgroundItem {
                id: login

                width: parent.width
                height: lblAcc1.height + lblAcc2.height + 2*Theme.paddingLarge + Theme.paddingSmall

                onClicked: {
                    console.log("old token:", authToken.value)
                    if(!authToken.value) {
                        var lpage = pageStack.push(Qt.resolvedUrl("LoginPage.qml"))
                        lpage.statusChanged.connect(function() {
                            if(lpage.status === PageStatus.Deactivating) {
                                getName()
                            }
                        })
                    }
                    else {
                        authToken.value = ""
                        console.log("Cookie cleaning script result code:", cpptools.clearCookies())
                        name = ""
                        mainWindow.username = ""
                    }
                }

                Label {
                    id: lblAcc1

                    anchors { top: parent.top
                              left: parent.left
                              right: parent.right
                              topMargin: Theme.paddingLarge
                              leftMargin: Theme.horizontalPageMargin
                              rightMargin: Theme.horizontalPageMargin
                            }
                    text: !authToken.value ? qsTr("Not logged in") : (qsTr("Logged in as ") + name)
                    color: login.highlighted ? Theme.highlightColor : Theme.primaryColor
                    font.pixelSize: Theme.fontSizeMedium
                }

                Label {
                    id: lblAcc2

                    anchors { bottom: parent.bottom
                              left: parent.left
                              right: parent.right
                              bottomMargin: Theme.paddingLarge
                              leftMargin: Theme.horizontalPageMargin
                              rightMargin: Theme.horizontalPageMargin
                            }
                    text: !authToken.value ? qsTr("Log in") : qsTr("Log out")
                    color: login.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
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
                menu: ContextMenu {
                    MenuItem { text: qsTr("High") }
                    MenuItem { text: qsTr("Medium") }
                    MenuItem { text: qsTr("Low") }
                }
                currentIndex: imageSizes.indexOf(gameImageSize.value)
            }

            ComboBox {
                id: previewQ

                label: qsTr("Stream previews quality")
                menu: ContextMenu {
                    MenuItem { text: qsTr("High") }
                    MenuItem { text: qsTr("Medium") }
                    MenuItem { text: qsTr("Low") }
                }
                currentIndex: imageSizes.indexOf(channelImageSize.value)
            }
        }

        VerticalScrollDecorator { flickable: parent }
    }
}

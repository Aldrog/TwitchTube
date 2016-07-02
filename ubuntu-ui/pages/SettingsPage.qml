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
import "../js/httphelper.js" as HTTP

Page {
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

    Component.onCompleted: {
        if(authToken.value)
            getName()
    }

    header: PageHeader {
        id: header

        title: qsTr("Settings")
        flickable: mainContainer
        trailingActionBar.actions: [
            Action {
                text: qsTr("Apply")
                iconName: "ok"

                onTriggered: {
                    gameImageSize.value = imageSizes[gameQ.selectedIndex]
                    channelImageSize.value = imageSizes[previewQ.selectedIndex]
                    showBroadcastTitles.value = streamTitles.checked
                    chatFlowBtT.value = chatTtB.checked
                    pageStack.pop()
                }
            },
            Action {
                text: qsTr("Cancel")
                iconName: "close"

                onTriggered: pageStack.pop()
            }
        ]
    }

    Flickable {
        id: mainContainer
        anchors.fill: parent
        contentHeight: header.height + settingsContainer.height + units.gu(2) // for bottom margin

        Column {
            id: settingsContainer

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            ListItem {
                id: login

                width: parent.width
                height: lblAcc1.height + lblAcc2.height + 2*units.gu(2) + units.gu(1)

                trailingActions: ListItemActions {
                    actions: [Action {
                    id: accountAction
                    text: !authToken.value ? qsTr("Log in") : qsTr("Log out")
                    iconName: "go-next"

                    onTriggered: {
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
                }]
                }

                onClicked: accountAction.trigger()

                Label {
                    id: lblAcc1

                    anchors { top: parent.top
                              left: parent.left
                              right: parent.right
                              topMargin: units.gu(2)
                              leftMargin: units.gu(2)
                              rightMargin: units.gu(2)
                            }
                    text: !authToken.value ? qsTr("Not logged in") : (qsTr("Logged in as ") + name)
                    font.pixelSize: FontUtils.sizeToPixels("medium")
                }

                Label {
                    id: lblAcc2

                    anchors { bottom: parent.bottom
                              left: parent.left
                              right: parent.right
                              bottomMargin: units.gu(2)
                              leftMargin: units.gu(2)
                              rightMargin: units.gu(2)
                            }
                    text: !authToken.value ? qsTr("Log in") : qsTr("Log out")
                    color: UbuntuColors.coolGrey
                    font.pixelSize: FontUtils.sizeToPixels("small")
                }
            }

            ListItem {
                width: parent.width

                Label {
                    anchors {
                        left: parent.left
                        top: parent.top
                        margins: units.gu(2)
                    }

                    text: qsTr("Show broadcast titles") }
                Switch {
                    id: streamTitles
                    anchors {
                        right: parent.right
                        top: parent.top
                        margins: units.gu(2)
                    }
                    checked: showBroadcastTitles.value
                }
            }

            ListItem {
                width: parent.width

                Label {
                    anchors {
                        left: parent.left
                        top: parent.top
                        margins: units.gu(2)
                    }

                    text: qsTr("Chat flows from bottom to top") }

                Switch {
                    id: chatTtB
                    anchors {
                        right: parent.right
                        top: parent.top
                        margins: units.gu(2)
                    }
                    checked: chatFlowBtT.value
                }
            }

            ListItem {
                width: parent.width
                height: gameQ.height + units.gu(4)

                OptionSelector {
                    id: gameQ

                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: units.gu(2)
                    }

                    text: qsTr("Game posters quality")
                    model: [
                        qsTr("High"),
                        qsTr("Medium"),
                        qsTr("Low")
                    ]
                    selectedIndex: imageSizes.indexOf(gameImageSize.value)
                }
            }

            ListItem {
                width: parent.width
                height: previewQ.height + units.gu(4)

                OptionSelector {
                    id: previewQ

                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: units.gu(2)
                    }

                    text: qsTr("Stream previews quality")
                    model: [
                        qsTr("High"),
                        qsTr("Medium"),
                        qsTr("Low")
                    ]
                    selectedIndex: imageSizes.indexOf(channelImageSize.value)
                }
            }
        }
    }
}

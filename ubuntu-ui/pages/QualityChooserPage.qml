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

Page {
    id: page

    property var qualities: ["chunked", "high", "medium", "low", "mobile"]
    property bool chatOnly
    property bool audioOnly

    signal accepted

    header: PageHeader {
        id: header

        title: qsTr("Stream properties")
        flickable: mainContainer
        trailingActionBar.actions: [
            Action {
                text: qsTr("Apply")
                iconName: "ok"

                onTriggered: {
                    streamQuality.value = qualities[qualityChooser.currentIndex]
                    chatOnly = chatOnlySwitch.checked
                    audioOnly = audioOnlySwitch.checked
                    accepted()
                    console.log("accepted")
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
        contentHeight: header.height + optionsContainer.height

        Column {
            id: optionsContainer

            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
            }

            ListItem {
                width: parent.width
                height: qualityChooser.height + units.gu(4)

                OptionSelector {
                    id: qualityChooser

                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: units.gu(2)
                    }

                    text: qsTr("Quality")
                    model: [
                        qsTr("Source"),
                        qsTr("High"),
                        qsTr("Medium"),
                        qsTr("Low"),
                        qsTr("Mobile")
                    ]
                    selectedIndex: qualities.indexOf(streamQuality.value)
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

                    text: qsTr("Chat only")
                }

                Switch {
                    id: chatOnlySwitch
                    anchors {
                        right: parent.right
                        top: parent.top
                        margins: units.gu(2)
                    }
                    checked: chatOnly

                    onCheckedChanged: {
                        if(checked)
                             audioOnlySwitch.checked = false
                     }
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

                    text: qsTr("Audio only")
                }

                Switch {
                    id: audioOnlySwitch
                    anchors {
                        right: parent.right
                        top: parent.top
                        margins: units.gu(2)
                    }
                    checked: audioOnly

                    onCheckedChanged: {
                        if(checked)
                            chatOnlySwitch.checked = false
                     }
                }
            }
        }
    }
}

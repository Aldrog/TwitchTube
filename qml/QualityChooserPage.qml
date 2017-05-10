/*
 * Copyright © 2016-2017 Andrew Penkrat
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

Dialog {
    id: page

    property var qualities

    // Set to false to forbid audio and chat only modes
    property bool allowVideoDisable: true

    property bool chatOnly
    property bool audioOnly

    Component.onCompleted: console.log(allowVideoDisable)

    onAccepted: {
        streamQuality.value = qualityChooser.currentIndex
        if(allowVideoDisable) {
            chatOnly = chatOnlySwitch.checked
            audioOnly = audioOnlySwitch.checked
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: header.height + optionsContainer.height

        DialogHeader {
            id: header
            title: qsTr("Playback options")
        }

        Column {
            id: optionsContainer

            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
            }

            ComboBox {
                id: qualityChooser

                width: parent.width
                label: qsTr("Quality")
                currentIndex: streamQuality.value < qualities.selectableQualities.length ? streamQuality.value : (qualities.selectableQualities.length - 1)

                menu: ContextMenu {
                    Repeater {
                        model: qualities.selectableQualities
                        delegate: MenuItem { text: qualities[modelData].name }
                    }
                }
            }

            TextSwitch {
                id: chatOnlySwitch
                checked: chatOnly
                text: qsTr("Chat only")
                visible: allowVideoDisable

                onCheckedChanged: {
                    if(checked)
                        audioOnlySwitch.checked = false
                }
            }

            TextSwitch {
                id: audioOnlySwitch
                checked: audioOnly
                text: qsTr("Audio only")
                visible: allowVideoDisable

                onCheckedChanged: {
                    if(checked)
                        chatOnlySwitch.checked = false
                }
            }
        }
    }
}

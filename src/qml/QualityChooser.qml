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
import QTwitch.Models 0.1

DockedPanel {
    property alias playlist: model
    property string streamUrl: audioOnly ? model.audioUrl : (quality.currentItem ? quality.currentItem.url : "")
    property alias audioOnly: audioSwitch.checked
    property alias chatOnly: chatSwitch.checked
    property bool empty: !menu.hasContent

    // Avoid dimming ComboBox's internal page
    modal: page.status !== PageStatus.Inactive
    dock: Dock.Bottom
    height: content.y + content.height + Theme.paddingLarge
    width: parent.width

    InterfaceConfiguration {
        id: config
        property int qualityId: 1
    }

    Column {
        id: content
        y: Theme.paddingLarge
        width: parent.width

        ComboBox {
            id: quality
            label: qsTr("Quality")

            menu: ContextMenu {
                Repeater {
                    id: repeater

                    model: PlaylistModel {
                        id: model
                    }

                    onItemAdded: {
                        if (index <= config.qualityId)
                            quality.currentIndex = index
                    }

                    MenuItem {
                        property string url: model.url
                        text: name
                        onClicked: {
                            config.qualityId = index
                        }
                    }
                }
            }
        }

        TextSwitch {
            id: audioSwitch
            text: qsTr("Audio only")
            checked: false

            onCheckedChanged: {
                if (checked)
                    chatSwitch.checked = false
            }
        }

        TextSwitch {
            id: chatSwitch
            text: qsTr("Chat only")
            checked: false

            onCheckedChanged: {
                if (checked)
                    audioSwitch.checked = false
            }
        }
    }
}

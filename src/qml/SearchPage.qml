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

Page {
    allowedOrientations: Orientation.All

    SilicaFlickable {
        id: rootFlickable
        anchors.fill: parent
        contentHeight: content.height + Theme.paddingLarge

        Column {
            id: content

            anchors {
                left: parent.left
                right: parent.right
                leftMargin: Theme.horizontalPageMargin - Theme.paddingSmall
                rightMargin: Theme.horizontalPageMargin - Theme.paddingSmall
            }

            SearchField {
                id: search
                property string category
                width: parent.width
                focus: true
                placeholderText: qsTr("Search %1").arg(category)
                label: qsTr("Search")
            }

            ComboBox {
                label: qsTr("What to search for")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Users")
                        onClicked: {
                            search.category = text
                        }
                    }
                    MenuItem {
                        text: qsTr("Live Channels")
                        onClicked: {
                            search.category = text
                        }
                    }
                    MenuItem {
                        text: qsTr("Games")
                        onClicked: {
                            search.category = text
                        }
                    }
                }
            }
        }

        VerticalScrollDecorator { flickable: rootFlickable }
    }
}

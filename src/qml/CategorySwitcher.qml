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
import QTwitch.Api 0.1

PersistentPanel {
    property alias category: config.category

    width: parent.width
    height: Theme.itemSizeLarge
    dock: Dock.Bottom
    open: true

    InterfaceConfiguration {
        id: config
        property string category: "games"
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        CategoryButton {
            id: games
            icon: "image://app-icons/games"
            active: category === "games"
            onClicked: {
                category = "games"
            }
        }

        CategoryButton {
            id: channels
            icon: "image://app-icons/streams"
            active: category === "channels"
            onClicked: {
                category = "channels"
            }
        }

        Loader {
            active: Client.authorizationStatus === Client.Authorized

            CategoryButton {
                id: follows
                icon: "image://theme/icon-m-favorite-selected"
                active: category === "follows"
                onClicked: {
                    category = "follows"
                }
            }
        }

        CategoryButton {
            id: search
            icon: "image://theme/icon-m-search"
            active: category === "search"
            onClicked: {
                category = "search"
            }
        }
    }
}

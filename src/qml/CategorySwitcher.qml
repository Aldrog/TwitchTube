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
    width: parent.width
    height: Theme.itemSizeLarge
    dock: Dock.Bottom
    open: true

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        BackgroundItem {
            id: games
            height: parent.height
            width: height

            Image {
                anchors.fill: parent
                source: "image://app-icons/games?" + (games.highlighted
                                                        ? Theme.highlightColor
                                                        : Theme.primaryColor)
            }
        }

        BackgroundItem {
            id: channels
            height: parent.height
            width: height

            Image {
                anchors.fill: parent
                source: "image://app-icons/streams?" + (channels.highlighted
                                                        ? Theme.highlightColor
                                                        : Theme.primaryColor)
            }
        }

        Loader {
            active: Client.authorizationStatus === Client.Authorized

            BackgroundItem {
                id: follows
                height: parent.height
                width: height

                Image {
                    anchors.fill: parent
                    source: "image://theme/icon-m-favorite-selected?" + (follows.highlighted
                                                            ? Theme.highlightColor
                                                            : Theme.primaryColor)
                }
            }
        }

        BackgroundItem {
            id: search
            height: parent.height
            width: height

            Image {
                anchors.fill: parent
                source: "image://theme/icon-m-search?" + (search.highlighted
                                                        ? Theme.highlightColor
                                                        : Theme.primaryColor)
            }
            onClicked: hide()
        }
    }
}

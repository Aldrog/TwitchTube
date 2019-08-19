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
            width: parent.width

            PageHeader {
                id: header
                title: qsTr("Follows")
            }

            ComboBox {
                id: gridSelector
                label: qsTr("Show followed")
                currentItem: streamsMenu

                menu: ContextMenu {
                    MenuItem {
                        id: usersMenu
                        readonly property Component grid: usersGrid
                        text: qsTr("Users")
                    }
                    MenuItem {
                        id: streamsMenu
                        readonly property Component grid: streamsGrid
                        text: qsTr("Live Streams")
                    }
                    MenuItem {
                        id: gamesMenu
                        readonly property Component grid: gamesGrid
                        text: qsTr("Games")
                    }
                }
            }

            Component {
                id: usersGrid
                UsersGrid {
                    model: FollowedUsersModel {
                        Component.onCompleted: reload()
                    }
                }
            }

            Component {
                id: streamsGrid
                StreamsGrid {
                    model: FollowedStreamsModel {
                        Component.onCompleted: reload()
                    }
                }
            }

            Component {
                id: gamesGrid
                GamesGrid {
                    model: FollowedGamesModel {
                        Component.onCompleted: reload()
                    }
                }
            }

            Loader {
                id: gridLoader
                width: parent.width
                sourceComponent: gridSelector.currentItem.grid
            }

            ContentLoader {
                model: gridLoader.item.model
                flickable: rootFlickable
            }
        }

        VerticalScrollDecorator { flickable: rootFlickable }
    }
}

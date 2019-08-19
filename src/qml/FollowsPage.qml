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
            }

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
                        property Component grid: usersGrid
                        text: qsTr("Users")
                    }
                    MenuItem {
                        id: streamsMenu
                        property Component grid: streamsGrid
                        text: qsTr("Live Streams")
                    }
                    MenuItem {
                        id: gamesMenu
                        property Component grid: gamesGrid
                        text: qsTr("Games")
                    }
                }
            }

            Component {
                id: usersGrid

                SimpleGrid {
                    id: grid

                    dpiWidth: 250
                    cellHeight: model.imageHeight + 2*Theme.paddingSmall

                    model: FollowedUsersModel {
                        imageWidth: grid.cellWidth - 2*Theme.paddingSmall
                        Component.onCompleted: reload()
                    }

                    delegate: EntitledImage {
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("UserPage.qml"), {userId: additionalData.userId})
                        }
                    }
                }
            }

            Component {
                id: streamsGrid

                SimpleGrid {
                    id: grid

                    dpiWidth: 250
                    cellHeight: model.imageHeight + 2*Theme.paddingSmall

                    model: FollowedStreamsModel {
                        imageWidth: grid.cellWidth - 2*Theme.paddingSmall
                        Component.onCompleted: reload()
                    }

                    delegate: EntitledImage {
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("StreamPage.qml"), {userId: additionalData.userId})
                        }
                    }
                }
            }

            Component {
                id: gamesGrid

                SimpleGrid {
                    id: grid

                    dpiWidth: 250
                    cellHeight: model.imageHeight + 2*Theme.paddingSmall

                    model: FollowedGamesModel {
                        imageWidth: grid.cellWidth - 2*Theme.paddingSmall
                        Component.onCompleted: reload()
                    }

                    delegate: EntitledImage {
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("GameStreamsPage.qml"), {gameId: additionalData.gameId, gameTitle: title})
                        }
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

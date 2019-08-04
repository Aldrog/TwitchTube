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

            SearchField {
                id: search
                property string category
                width: parent.width
                focus: true
                placeholderText: qsTr("Search %1").arg(category)
                label: qsTr("Search")
            }

            ComboBox {
                label: qsTr("Search for")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Users")
                        onClicked: {
                            search.category = text
                            gridLoader.category = "users"
                        }
                    }
                    MenuItem {
                        text: qsTr("Live Streams")
                        onClicked: {
                            search.category = text
                            gridLoader.category = "streams"
                        }
                    }
                    MenuItem {
                        text: qsTr("Games")
                        onClicked: {
                            search.category = text
                            gridLoader.category = "games"
                        }
                    }
                }
            }

            Component {
                id: usersGrid

                SimpleGrid {
                    id: grid

                    dpiWidth: 250
                    cellHeight: model.imageHeight + 2*Theme.paddingSmall

                    model: UsersSearchModel {
                        imageWidth: grid.cellWidth - 2*Theme.paddingSmall
                        query: search.text
                        onQueryChanged: reload()
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

                    model: StreamsSearchModel {
                        imageWidth: grid.cellWidth - 2*Theme.paddingSmall
                        query: search.text
                        onQueryChanged: reload()
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

                    model: GamesSearchModel {
                        imageWidth: grid.cellWidth - 2*Theme.paddingSmall
                        query: search.text
                        onQueryChanged: reload()
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
                property string category: "users"

                width: parent.width
                sourceComponent: {
                    if (category === "users")
                        return usersGrid
                    if (category === "streams")
                        return streamsGrid
                    if (category === "games")
                        return gamesGrid
                }
            }

            ContentLoader {
                model: gridLoader.item.model
                flickable: rootFlickable
            }
        }

        VerticalScrollDecorator { flickable: rootFlickable }
    }
}

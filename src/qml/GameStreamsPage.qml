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
    property string gameId
    property string gameTitle

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

            PageHeader {
                id: header
                title: gameTitle
            }

            SimpleGrid {
                id: grid

                dpiWidth: 350
                cellHeight: model.imageHeight + 2*Theme.paddingSmall

                model: StreamsModel {
                    imageWidth: grid.cellWidth - 2*Theme.paddingSmall
                    gameFilter: [ gameId ]
                    Component.onCompleted: reload()
                }

                delegate: BackgroundItem {
                    id: item

                    width: grid.cellWidth
                    height: grid.cellHeight

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("StreamPage.qml"), { userId: additionalData.userId })
                    }

                    Image {
                        id: img
                        anchors.fill: parent
                        anchors.margins: Theme.paddingSmall
                        fillMode: Image.PreserveAspectCrop
                        source: image
                    }

                    OpacityRampEffect {
                        property real effHeight: name.height
                        sourceItem: img
                        direction: OpacityRamp.BottomToTop
                        offset: 1 - 1.25 * (effHeight / img.height)
                        slope: img.height / effHeight
                    }

                    Label {
                        id: name
                        anchors {
                            left: img.left; leftMargin: Theme.paddingMedium
                            right: img.right; rightMargin: Theme.paddingSmall
                            topMargin: Theme.paddingSmall
                        }
                        truncationMode: TruncationMode.Fade
                        color: item.highlighted ? Theme.highlightColor : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        text: title
                    }
                }
            }

            ContentLoader {
                model: grid.model
                flickable: rootFlickable
            }
        }

        VerticalScrollDecorator { flickable: rootFlickable }
    }
}

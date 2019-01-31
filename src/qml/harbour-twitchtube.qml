/*
 * Copyright © 2015-2017, 2019 Andrew Penkrat
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

import QtQuick 2.6
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import QTwitch.Models 0.1

ApplicationWindow {
    id: mainWindow

    property string username
    property string audioUrl
    property string currentCategory: "games"
    property bool playing: player.playbackState == MediaPlayer.PlayingState

    signal audioOn
    signal audioOff

    function playAudio() {
        player.source = audioUrl
        player.play()
    }

    function stopAudio() {
        player.stop()
        player.source = ""
    }

    initialPage: Component { Page {
        SilicaGridView {
            id: grid

            property int rowSize: isPortrait ? 2 : 4
            property real aspectRatio: 4/3
//            anchors.fill: parent

            header: PageHeader {
                id: header
                title: qsTr("Games")
            }

            anchors.leftMargin: Theme.horizontalPageMargin - Theme.paddingSmall
            anchors.rightMargin: Theme.horizontalPageMargin - Theme.paddingSmall
            cellWidth: width/rowSize
            cellHeight: cellWidth * aspectRatio

            model: TopGamesModel { }

            delegate: BackgroundItem {
                id: item

                width: grid.cellWidth
                height: grid.cellHeight

                onClicked: {
                    panel.show()
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
            anchors.fill: parent

//            clip: true
            VerticalScrollDecorator { flickable: grid }
        }
    } }

    bottomMargin: panel.visibleSize

    CategorySwitcher {
        id: panel
    }

    MediaPlayer {
        id: player
        autoLoad: false
        onSourceChanged: console.log(source)
    }
}

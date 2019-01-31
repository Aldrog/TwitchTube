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

    function switchCategory(category) {
        if (category === "games")
            pageStack.replaceAbove(Qt.resolvedUrl("GamesPage.qml"))
    }

    initialPage: Component { GamesPage { } }

    bottomMargin: panel.visibleSize

    CategorySwitcher {
        id: panel
        onCategoryChanged: switchCategory(category)
    }

    Component.onCompleted: {
        switchCategory(panel.category)
    }

    MediaPlayer {
        id: player
        autoLoad: false
        onSourceChanged: console.log(source)
    }
}

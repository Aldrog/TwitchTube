/*
 * Copyright © 2017 Andrew Penkrat
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

import QtQuick 2.1
import Sailfish.Silica 1.0
import QtMultimedia 5.5

Rectangle {
    id: videoBackground

    function stopPlayback() {
        video.stop()
        video.source = ""
        cpptools.setBlankingMode(true)
    }

    function startPlayback(url) {
        if(!url) {
            video.play()
            cpptools.setBlankingMode(false)
        } else if(video.source !== url) {
            video.stop()
            video.source = url
            video.play()
            cpptools.setBlankingMode(false)
        }
    }

    color: "black"

    Video {
        id: video
        anchors.fill: parent

        autoLoad: false
        onErrorChanged: console.error("video error:", errorString)

        BusyIndicator {
            anchors.centerIn: parent
            running: video.status === MediaPlayer.NoMedia
                  || video.status === MediaPlayer.Loading
                  //|| video.status === MediaPlayer.Stalled
            size: isPortrait ? BusyIndicatorSize.Medium : BusyIndicatorSize.Large
        }
    }
}

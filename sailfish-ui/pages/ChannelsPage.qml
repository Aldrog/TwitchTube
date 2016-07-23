/*
 * Copyright © 2015-2016 Andrew Penkrat
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
import "elements"
import "../js/httphelper.js" as HTTP

Page {
    id: page

    // Status for NavigationCover
    property string navStatus: qsTr("Channels")

    allowedOrientations: Orientation.All

    GridWrapper {
        header.title: qsTr("Top Channels")

        grids: [
        StreamsGrid {
            id: gridChannels

            function loadContent() {
                var url = "https://api.twitch.tv/kraken/streams?limit=" + countOnPage + "&offset=" + offset
                HTTP.getRequest(url,function(data) {
                    if (data) {
                        offset += countOnPage
                        var result = JSON.parse(data)
                        totalCount = result._total
                        for (var i in result.streams)
                            channels.append(result.streams[i])
                    }
                })
            }
        }]

        Categories {
            channels: false
        }
    }
}

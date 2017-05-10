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
import "implementation"
import "js/httphelper.js" as HTTP

Page {
    id: page

    property string channel
    property string display
    // Status for NavigationCover
    property string navStatus: display

    onStatusChanged: {
        if(status === PageStatus.Active)
            pageStack.pushAttached(Qt.resolvedUrl("ChannelBroadcastsPage.qml"), {channel: channel, display: display})
    }

    GridWrapper {
        header.title: qsTr("Highlights by %1").arg(display)

        grids: [
            VodsGrid {
                id: gridHighlights

                function loadContent() {
                    var url = "https://api.twitch.tv/kraken/channels/" + channel + "/videos?broadcasts=false&hls=true&limit=" + countOnPage + "&offset=" + offset
                    HTTP.getRequest(url,function(data) {
                        if (data) {
                            offset += countOnPage
                            var result = JSON.parse(data)
                            totalCount = result._total
                            for (var i in result.videos)
                                vods.append(result.videos[i])
                        }
                    })
                }
            }]

        Categories {
            search: mainWindow.currentCategory !== "search"
            following: mainWindow.currentCategory !== "following"
            channels: mainWindow.currentCategory !== "channels"
            games: mainWindow.currentCategory !== "games"
        }
    }
}

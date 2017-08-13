/*
 * Copyright © 2015-2017 Andrew Penkrat
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

    title: qsTr("Broadcasts by %1").arg(display)

    GridWrapper {
        id: gridContainer

        ImageGrid {
            id: gridHighlights

            function loadContent() {
                var url = "https://api.twitch.tv/kraken/channels/" + channel + "/videos?broadcasts=true&hls=true&limit=" + pageSize + "&offset=" + offset
                HTTP.getRequest(url,function(data) {
                    if (data) {
                        offset += pageSize
                        var result = JSON.parse(data)
                        totalCount = result._total
                        for (var i in result.videos) {
                            var vod = result.videos[i]
                            model.append({ image: vod.preview, title: vod.title, id: ~~(vod._id.substring(1)), description: vod.description })
                        }
                        gridContainer.gridsChanged()
                    }
                })
            }

            rowSize: isPortrait ? 2 : 3
            pageSize: 2*3 * 3
            aspectRatio: 9/16

            onClicked: {
                var properties = ({})
                properties.vodId = item.id
                properties.vodDetails = { title: item.title, description: item.description }
                pageStack.push(Qt.resolvedUrl("VodPage.qml"), properties)
            }
        }
    }

    Categories {
        search: mainWindow.currentCategory !== "search"
        following: mainWindow.currentCategory !== "following"
        channels: mainWindow.currentCategory !== "channels"
        games: mainWindow.currentCategory !== "games"
    }
}

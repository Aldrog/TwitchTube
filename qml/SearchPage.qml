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

    // Status for NavigationCover
    property string navStatus: qsTr("Search")

    GridWrapper {
        id: gridContainer

        ImageGrid {
            id: gridResults

            property string querry: ""

            function loadContent() {
                if(querry) {
                    var url = "https://api.twitch.tv/kraken/search/streams?q=" + querry + "&limit=" + pageSize + "&offset=" + offset
                    console.log(url)
                    HTTP.getRequest(url,function(data) {
                        if (data) {
                            offset += pageSize
                            var result = JSON.parse(data)
                            totalCount = result._total
                            for (var i in result.streams) {
                                var stream = result.streams[i]
                                model.append({ images: stream.preview, title: stream.channel.display_name, subtitle: stream.channel.status, channel: stream.channel.name })
                            }
                        }
                    })
                }
                else {
                    totalCount = 0
                    model.clear()
                }
            }

            autoLoad: false

            // This prevents search field from loosing focus when grid changes
            currentIndex: -1

            rowSize: isPortrait ? 2 : 3
            pageSize: 2*3 * 3
            aspectRatio: 9/16
            imageIndex: channelImageSize.value
            showSubtitles: showBroadcastTitles.value

            onClicked: {
                pageStack.push (Qt.resolvedUrl("StreamPage.qml"), { channel: item.channel, channelDisplay: item.title })
            }

            header: SearchField {
                id: searchQuerry

                width: parent.width
                placeholderText: qsTr("Search channels")
                onTextChanged: {
                    gridResults.model.clear()
                    gridResults.offset = 0
                    gridResults.querry = text
                    gridResults.loadContent()
                }
            }
        }
    }

    Categories {
        search: false
    }
}

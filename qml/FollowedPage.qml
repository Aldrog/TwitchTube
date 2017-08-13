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
    property string navStatus: qsTr("Following")

    onStatusChanged: {
        if(status === PageStatus.Active)
            pageStack.pushAttached(Qt.resolvedUrl("FollowedGamesPage.qml"))
    }

    title: qsTr("Followed Streams")

    //contentHeight: gridChannels.height + header.height + gridOffline.height - gridOffline.headerItem.height + Theme.paddingLarge

    GridWrapper {
        id: gridContainer

        ImageGrid {
            id: gridChannels

            function loadContent() {
                var url = "https://api.twitch.tv/kraken/streams/followed?limit=" + pageSize + "&offset=" + offset + "&oauth_token=" + authToken.value
                console.log(url)
                HTTP.getRequest(url, function(data) {
                    if (data) {
                        offset += pageSize
                        var result = JSON.parse(data)
                        totalCount = result._total
                        for (var i in result.streams) {
                            var stream = result.streams[i]
                            model.append({ images: stream.preview, title: stream.channel.display_name, subtitle: stream.channel.status, channel: stream.channel.name })
                        }
                        gridContainer.gridsChanged()
                    }
                })
            }

            rowSize: isPortrait ? 2 : 3
            pageSize: 2*3 * 3
            aspectRatio: 9/16
            imageIndex: channelImageSize.value
            showSubtitles: showBroadcastTitles.value

            onClicked: {
                pageStack.push (Qt.resolvedUrl("StreamPage.qml"), { channel: item.channel, channelDisplay: item.title })
            }
        }

        ImageGrid {
            id: gridOffline

            loadText: qsTr("Show all channels")

            visible: false
            autoLoad: false

            header: SectionHeader {
                text: qsTr("Channels")
            }

            function loadContent() {
                var url = "https://api.twitch.tv/kraken/users/" + mainWindow.username + "/follows/channels?limit=" + pageSize + "&offset=" + offset + "&sortby=last_broadcast"
                console.log(url)
                HTTP.getRequest(url, function(data) {
                    if (data) {
                        offset += pageSize
                        var result = JSON.parse(data)
                        totalCount = result._total
                        for (var i in result.follows) {
                            var channel = result.follows[i].channel
                            model.append({ image: channel.logo, title: channel.display_name, channel: channel.name })
                        }
                        gridContainer.gridsChanged()
                    }
                })
            }

            rowSize: isPortrait ? 2 : 3
            pageSize: 2*3 * 3
            aspectRatio: 1

            onClicked: {
                pageStack.push (Qt.resolvedUrl("ChannelPage.qml"), { channel: item.channel, display: item.title })
            }
        }
    }

    Categories {
        following: false
    }
}

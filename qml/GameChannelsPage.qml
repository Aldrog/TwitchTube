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

    property string game
    property bool followed
    property bool fromFollowings: false
    // Status for NavigationCover
    property string navStatus: game

    function checkIfFollowed() {
        followed = false
        if(mainWindow.username) {
            HTTP.getRequest("https://api.twitch.tv/api/users/" + mainWindow.username + "/follows/games/" + game, function(data) {
                if(data)
                    followed = true
                else
                    followed = false
            })
        }
    }

    title: game

    headerContent: [
        IconButton {
            id: switchFollow

            visible: mainWindow.username

            iconName: followed ? "heart_crossed" : "heart"

            Component.onCompleted: checkIfFollowed()
            onVisibleChanged: checkIfFollowed()

            onClicked: {
                if(!followed)
                    HTTP.putRequest("https://api.twitch.tv/api/users/" + username + "/follows/games/" + game + "?oauth_token=" + authToken.value, function(data) {
                        if(data)
                            followed = true
                    })
                else
                    HTTP.deleteRequest("https://api.twitch.tv/api/users/" + username + "/follows/games/" + game + "?oauth_token=" + authToken.value, function(data) {
                        if(data === 204)
                            followed = false
                    })
            }
        }]


    GridWrapper {
        id: gridContainer

        ImageGrid {
            id: gridChannels

            function loadContent() {
                var url = "https://api.twitch.tv/kraken/streams?limit=" + pageSize + "&offset=" + offset + encodeURI("&game=" + game)
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

            rowSize: isPortrait ? 2 : 3
            pageSize: 2*3 * 3
            aspectRatio: 9/16
            imageIndex: channelImageSize.value
            showSubtitles: showBroadcastTitles.value

            onClicked: {
                pageStack.push (Qt.resolvedUrl("StreamPage.qml"), { channel: item.channel, channelDisplay: item.title })
            }
        }
    }

    Categories {
        games: fromFollowings
        following: !fromFollowings && mainWindow.username
    }
}

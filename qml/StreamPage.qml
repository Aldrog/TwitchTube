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
import QtMultimedia 5.0
import harbour.twitchtube.ircchat 1.0
import "implementation"
import "js/httphelper.js" as HTTP

Page {
    id: page

    property var urls: { selectableQualities: [] }
    property string channel
    property string channelDisplay
    property bool followed
    property bool chatMode: false
    property bool audioMode: false
    property bool active: Qt.application.active
    property bool fullscreenConditions: isLandscape && flickable.visibleArea.yPosition === 0 && !flickable.moving && !state && video.visible
    property string source: urls[urls.selectableQualities[streamQuality.value < urls.selectableQualities.length ?
                                                          streamQuality.value : urls.selectableQualities.length - 1]
                                ].url

    function findUrls(list) {
        var res = ({selectableQualities: []})
        var currentUrlId = ""
        var currentUrlName = ""
        for (var i in list) {
            if(list[i].substring(0, 12) === "#EXT-X-MEDIA") {
                currentUrlId = list[i].match(/GROUP-ID="([^"]+)"/)[1]
                currentUrlName = list[i].match(/NAME="([^"]+)"/)[1]
                if(list[i].indexOf("DEFAULT=YES") >= 0)
                    res.selectableQualities.push(currentUrlId)
            }
            if(list[i][0] !== '#' && list[i] !== "") {
                res[currentUrlId] = {
                    name: currentUrlName,
                    url: list[i]
                }
            }
        }
        console.log("Available qualities:", res.selectableQualities)
        return res
    }

    function loadStreamInfo() {
        HTTP.getRequest("https://api.twitch.tv/api/channels/" + channel + "/access_token" + (authToken.value ? ("?oauth_token=" + authToken.value) : ""), function (tokendata) {
            if (tokendata) {
                var token = JSON.parse(tokendata)
                HTTP.getRequest(encodeURI("http://usher.twitch.tv/api/channel/hls/" + channel + ".json?allow_source=true&allow_audio_only=true&" +
                                          "sig=" + token.sig + "&token=" + token.token + "&type=any&p=" + Math.floor(Math.random() * 1e8)),
                                function (data) {
                    if (data) {
                        var videourls = data.split('\n')
                        urls = findUrls(videourls)
                        mainWindow.audioUrl = urls.audio_only.url
                    }
                })
            }
        })
    }

    function checkFollow() {
        if(mainWindow.username) {
            HTTP.getRequest("https://api.twitch.tv/kraken/users/" + mainWindow.username + "/follows/channels/" + channel, function(data) {
                if(data)
                    followed = true
            })
        }
        followed = false
    }

    onSourceChanged: video.startPlayback(source)

    onChatModeChanged: {
        if(chatMode) {
            video.stopPlayback()
            mainWindow.stopAudio()
        }
    }

    onOpened: mainWindow.streamOpened(channel)
    onClosed: mainWindow.streamClosed()

    Connections {
        target: mainWindow

        onAudioOn: {
            if(chatMode) {
                chatMode = false
                audioMode = true
            }
        }

        onAudioOff: {
            if(audioMode) {
                chatMode = true
                audioMode = false
            }
        }
    }

    onActiveChanged: {
        if(active) {
            if(!audioMode) {
                mainWindow.stopAudio()
                if(!chatMode)
                    video.startPlayback()
            }
            if(!twitchChat.connected) {
                twitchChat.reopenSocket()
                twitchChat.join(channel)
            }
        }
        else {
            video.stopPlayback()
            if(twitchChat.connected)
                twitchChat.disconnect()
        }
    }

    onAudioModeChanged: {
        if(active) {
            if(audioMode === true) {
                video.stopPlayback()
                mainWindow.playAudio()
            }
            else {
                mainWindow.stopAudio()
                if(!chatMode)
                    video.startPlayback(source)
            }
        }
    }

    Component.onCompleted: {
        loadStreamInfo()
        checkFollow()
    }

    Timer {
        id: fullscreenTimer

        interval: 3000
        running: fullscreenConditions
        onTriggered: page.state = "fullscreen"
    }

//        contentHeight: isPortrait ? page.height : ((chatMode || audioMode) ? page.height : (5/3 * Screen.width))

//        PullDownMenu {
//            id: streamMenu

//            MenuItem {
//                text: qsTr("Past Broadcasts & Highlights")
//                onClicked: {
//                    var page = pageStack.push(Qt.resolvedUrl("ChannelPage.qml"), {channel: channel, display: channelDisplay})
//                    console.log(PageStatus.Deactivating, PageNavigation.Back)
//                    page.statusChanged.connect(function() {
//                        if(page.status === PageStatus.Deactivating && page._navigation === PageNavigation.Back) {
//                            video.startPlayback()
//                            if(!twitchChat.connected) {
//                                twitchChat.reopenSocket()
//                                twitchChat.join(channel)
//                            }
//                        }
//                    })
//                    mainWindow.streamClosed()
//                    video.stopPlayback()
//                    if(twitchChat.connected)
//                        twitchChat.disconnect()
//                }
//            }

//            MenuItem {
//                text: qsTr("Follow")
//                onClicked: HTTP.putRequest("https://api.twitch.tv/kraken/users/" + mainWindow.username + "/follows/channels/" + channel + "?oauth_token=" + authToken.value, function(data) {
//                    if(data)
//                        followed = true
//                })
//                visible: mainWindow.username && !followed
//            }

//            MenuItem {
//                text: qsTr("Unfollow")
//                onClicked: HTTP.deleteRequest("https://api.twitch.tv/kraken/users/" + mainWindow.username + "/follows/channels/" + channel + "?oauth_token=" + authToken.value, function(data) {
//                    if(data === 204)
//                        followed = false
//                })
//                visible: mainWindow.username && followed
//            }

//            MenuItem {
//                text: qsTr("Quality")
//                enabled: urls != null
//                onClicked: {
//                    var dialog = pageStack.push(Qt.resolvedUrl("QualityChooserPage.qml"), { qualities: urls, chatOnly: chatMode, audioOnly: audioMode, channel: channel })
//                    dialog.accepted.connect(function() {
//                        video.checkSource()
//                        chatMode = dialog.chatOnly
//                        audioMode = dialog.audioOnly
//                    })
//                }
//            }
//        }

    VideoPlayer {
        id: video

        width: parent.width
        height: width * 9/16 //(!chatMode && !audioMode) ? (isPortrait ? screen.width * 9/16 : screen.width) : 0
        visible: (!chatMode && !audioMode)

        StreamOverlay {
            onFullscreenTriggered: {
                page.state = !page.state ? "fullscreen" : ""
            }
        }
    }

    Chat {
        id: chat
        chatModel: twitchChat.messages
        displayMessageField: twitchChat.anonymous
        connected: twitchChat.connected

        width: parent.width
        height: Math.max(page.height - video.height, page.height * 2/3)

        IrcChat {
            id: twitchChat

            name: mainWindow.username
            password: 'oauth:' + authToken.value
            anonymous: !mainWindow.username
            textSize: Theme.chatFontPixelSize

            Component.onCompleted: {
                twitchChat.join(channel)
            }

            onErrorOccured: {
                console.log("Chat error: ", errorDescription)
            }

            onConnectedChanged: {
                console.log(connected)
            }
        }
    }

    states: State {
        name: "fullscreen"

        PropertyChanges {
            target: chat
            visible: false
        }

//        PropertyChanges {
//            target: streamMenu
//            visible: false
//            active: false
//        }

        PropertyChanges {
            target: page
            showNavigationIndicator: false; backNavigation: false
            allowedOrientations: landscapeOrientation
        }
    }
}

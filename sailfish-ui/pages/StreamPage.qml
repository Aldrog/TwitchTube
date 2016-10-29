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
import QtMultimedia 5.0
import harbour.twitchtube.ircchat 1.0
import "../js/httphelper.js" as HTTP

Page {
    id: page

    property var urls
    property string channel
    property string channelDisplay
    property bool followed
    property bool chatMode: false
    property bool audioMode: false
    property bool active: Qt.application.active
    property bool fullscreenConditions: isLandscape && main.visibleArea.yPosition === 0 && !main.moving && !state && video.visible

    function findUrl(s, q) {
        for (var x in s) {
            if (s[x].substring(0,4) === "http" && s[x].indexOf(q) >= 0)
                return s[x]
        }
    }

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
                        video.startPlayback()
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

    onChatModeChanged: {
        if(chatMode) {
            video.stopPlayback()
            mainWindow.stopAudio()
        }
    }

    allowedOrientations: Orientation.All

    onStatusChanged: {
        if(status === PageStatus.Activating) {
            mainWindow.currentChannel = channel
            mainWindow.cover = Qt.resolvedUrl("../cover/StreamCover.qml")
        }
        if(status === PageStatus.Deactivating) {
            if (_navigation === PageNavigation.Back) {
                mainWindow.cover = Qt.resolvedUrl("../cover/NavigationCover.qml")
            }
        }
    }

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
        if(page.status === PageStatus.Active) {
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
                    video.startPlayback()
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

    SilicaFlickable {
        id: main

        anchors.fill: parent
        contentHeight: isPortrait ? page.height : ((chatMode || audioMode) ? page.height : (5/3 * Screen.width))
        //onContentHeightChanged: console.log(contentHeight, height + Screen.width, Screen.width, chat.height)

        PullDownMenu {
            id: streamMenu

            MenuItem {
                text: qsTr("Past Broadcasts & Highlights")
                onClicked: {
                    var page = pageStack.push(Qt.resolvedUrl("ChannelPage.qml"), {channel: channel, display: channelDisplay})
                    console.log(PageStatus.Deactivating, PageNavigation.Back)
                    page.statusChanged.connect(function() {
                        if(page.status === PageStatus.Deactivating && page._navigation === PageNavigation.Back) {
                            video.startPlayback()
                            if(!twitchChat.connected) {
                                twitchChat.reopenSocket()
                                twitchChat.join(channel)
                            }
                        }
                    })
                    mainWindow.cover = Qt.resolvedUrl("../cover/NavigationCover.qml")
                    video.stopPlayback()
                    if(twitchChat.connected)
                        twitchChat.disconnect()
                }
            }

            MenuItem {
                text: qsTr("Follow")
                onClicked: HTTP.putRequest("https://api.twitch.tv/kraken/users/" + mainWindow.username + "/follows/channels/" + channel + "?oauth_token=" + authToken.value, function(data) {
                    if(data)
                        followed = true
                })
                visible: mainWindow.username && !followed
            }

            MenuItem {
                text: qsTr("Unfollow")
                onClicked: HTTP.deleteRequest("https://api.twitch.tv/kraken/users/" + mainWindow.username + "/follows/channels/" + channel + "?oauth_token=" + authToken.value, function(data) {
                    if(data === 204)
                        followed = false
                })
                visible: mainWindow.username && followed
            }

            MenuItem {
                text: qsTr("Quality")
                enabled: urls != null
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("QualityChooserPage.qml"), { qualities: urls, chatOnly: chatMode, audioOnly: audioMode, channel: channel })
                    dialog.accepted.connect(function() {
                        video.checkSource()
                        chatMode = dialog.chatOnly
                        audioMode = dialog.audioOnly
                    })
                }
            }
        }

        Rectangle {
            id: videoBackground

            color: "black"
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
            height: (!chatMode && !audioMode) ? (isPortrait ? screen.width * 9/16 : screen.width) : 0
            visible: (!chatMode && !audioMode)

            Video {
                id: video
                anchors.fill: parent

                function stopPlayback() {
                    stop()
                    source = ""
                    cpptools.setBlankingMode(true)
                }

                function startPlayback() {
                    source = urls[urls.selectableQualities[streamQuality.value < urls.selectableQualities.length ?
                                                           streamQuality.value : urls.selectableQualities.length - 1]
                                 ].url
                    play()
                    cpptools.setBlankingMode(false)
                }

                function checkSource() {
                    if(source !== urls[urls.selectableQualities[streamQuality.value < urls.selectableQualities.length ?
                                                                streamQuality.value : urls.selectableQualities.length - 1]
                                      ].url) {
                        stopPlayback()
                        startPlayback()
                    }
                }

                autoLoad: false
                onErrorChanged: console.error("video error:", errorString)

                BusyIndicator {
                    anchors.centerIn: parent
                    running: video.status === MediaPlayer.NoMedia
                          || video.status === MediaPlayer.Loading
                          //|| video.status === MediaPlayer.Stalled
                    size: isPortrait ? BusyIndicatorSize.Medium : BusyIndicatorSize.Large
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        page.state = !page.state ? "fullscreen" : ""
                    }
                }
            }
        }

        TextField {
            id: chatMessage

            anchors {
                left: parent.left
                right: parent.right
                top: chatFlowBtT.value ? videoBackground.bottom : undefined
                bottom: chatFlowBtT.value ? undefined : parent.bottom
                topMargin: (chatMode || audioMode) ? Theme.paddingLarge : Theme.paddingMedium
                bottomMargin: Theme.paddingMedium
            }
            // Maybe it's better to replace ternary operators with if else blocks
            placeholderText: twitchChat.connected ? (twitchChat.anonymous ? qsTr("Please log in to send messages") : qsTr("Type your message here")) : qsTr("Chat is not available")
            label: twitchChat.connected ? (twitchChat.anonymous ? qsTr("Please log in to send messages") : qsTr("Type your message here")) : qsTr("Chat is not available")
            EnterKey.iconSource: "image://theme/icon-m-enter-accept"
            EnterKey.enabled: text.length > 0 && twitchChat.connected && !twitchChat.anonymous
            EnterKey.onClicked: {
                twitchChat.sendMessage(text)
                text = ""
            }
        }

        SilicaListView {
            id: chat

            property bool atEnd: true

            anchors {
                left: parent.left
                right: parent.right
                top: chatFlowBtT.value ? chatMessage.bottom : videoBackground.bottom
                bottom: chatFlowBtT.value ? parent.bottom : chatMessage.top
            }

            preferredHighlightEnd: chat.height
            clip: true
            verticalLayoutDirection: chatFlowBtT.value ? ListView.BottomToTop : ListView.TopToBottom

            onMovementStarted: {
                atEnd = false
                currentIndex = -1
            }

            onMovementEnded: {
                if(chat.atYEnd) {
                    atEnd = true
                    currentIndex = count - 1
                }
            }

            // This makes sure individual messages don't get lost
            onAtYEndChanged: {
                if(atEnd && !atYEnd)
                    currentIndex = chat.count - 1
            }

            model: twitchChat.messages
            delegate: Item {
                height: lbl.height
                width: chat.width

                property bool viewed: false

                // This is the main handler for chat autoscroll, though it only works when messages count's increased
                // above there's additional handler covering this case
                ListView.onAdd: {
                    if(!viewed && chat.atEnd) {
                        chat.currentIndex = chat.count - 1
                    }
                    viewed = true
                }

                Label {
                    id: lbl

                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.horizontalPageMargin
                        rightMargin: Theme.horizontalPageMargin
                    }

                    text: richTextMessage
                    textFormat: Text.RichText
                    wrapMode: Text.WordWrap
                    color: isNotice ? Theme.highlightColor : Theme.primaryColor
                }
            }

            IrcChat {
                id: twitchChat

                name: mainWindow.username
                password: 'oauth:' + authToken.value
                anonymous: !mainWindow.username
                textSize: Theme.fontSizeMedium

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

            ViewPlaceholder {
                id: chatPlaceholder

                text: twitchChat.connected ? qsTr("Welcome to the chat room") : qsTr("Connecting to chat...")
                enabled: chat.count <= 0
                verticalOffset: -(chat.verticalLayoutDirection == ListView.TopToBottom ? (page.height - chat.height) / 2 : page.height - (page.height - chat.height) / 2)
            }

            VerticalScrollDecorator { flickable: chat }
        }
        //VerticalScrollDecorator { flickable: main }
    }

    states: State {
        name: "fullscreen"
        PropertyChanges {
            target: main
            contentHeight: page.height
        }

        PropertyChanges {
            target: chatMessage
            visible: false
        }

        PropertyChanges {
            target: chat
            visible: false
        }

        PropertyChanges {
            target: streamMenu
            visible: false
            active: false
        }

        PropertyChanges {
            target: page
            showNavigationIndicator: false; backNavigation: false
            allowedOrientations: Orientation.Landscape | Orientation.LandscapeInverted
        }
    }
}

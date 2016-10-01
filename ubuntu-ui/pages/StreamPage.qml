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

import QtQuick 2.4
import Ubuntu.Components 1.3
import QtMultimedia 5.0
import aldrog.twitchtube.ircchat 1.0
import "../js/httphelper.js" as HTTP

Page {
    id: page

    property var url
    property string channel
    property string username
    property bool followed
    property bool chatMode: false
    property bool audioMode: false
    property bool active: Qt.application.active
    property bool isLandscape: width > height
    property bool isPortrait: !isLandscape
    property bool fullscreenConditions: isLandscape && main.visibleArea.yPosition === 0 && !main.moving && !state && video.visible

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
        HTTP.getRequest("http://api.twitch.tv/api/channels/" + channel + "/access_token?oauth_token=" + authToken.value, function (tokendata) {
            if (tokendata) {
                var token = JSON.parse(tokendata)
                HTTP.getRequest(encodeURI("http://usher.twitch.tv/api/channel/hls/" + channel + ".json?allow_source=true&allow_audio_only=true&" +
                                          "sig=" + token.sig + "&token=" + token.token + "&type=any&p=" + Math.floor(Math.random() * 1e8)),
                                function (data) {
                    if (data) {
                        var videourls = data.split('\n')
                        urls = findUrls(videourls)
                        video.play()
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
        if(chatMode)
            video.stop()
    }

//    onStatusChanged: {
//        if(status === PageStatus.Activating) {
//            mainWindow.currentChannel = channel
//            mainWindow.cover = Qt.resolvedUrl("../cover/StreamCover.qml")
//            cpptools.setBlankingMode(false)
//        }
//        if(status === PageStatus.Deactivating) {
//            if (_navigation === PageNavigation.Back) {
//                mainWindow.cover = Qt.resolvedUrl("../cover/NavigationCover.qml")
//            }
//            cpptools.setBlankingMode(true)
//        }
//    }

//    onActiveChanged: {
//        if(page.status === PageStatus.Active) {
//            if(active) {
//                mainWindow.stopAudio()
//                video.play()
//                if(!twitchChat.connected) {
//                    twitchChat.reopenSocket()
//                    twitchChat.join(channel)
//                }
//            }
//            else {
//                video.pause()
//                if(audioMode)
//                    mainWindow.playAudio()
//                if(twitchChat.connected)
//                    twitchChat.disconnect()
//            }
//        }
//    }

    Component.onCompleted: {
        loadStreamInfo()
        followed = checkFollow()
    }

    header: PageHeader {
        title: channel
        flickable: main

        trailingActionBar.actions: [
            Action {
                enabled: mainWindow.username
                iconName: followed ? "starred" : "non-starred"
                name: followed ? qsTr("Unfollow") : qsTr("Follow")

                onTriggered: {
                    if(!followed) {
                        HTTP.putRequest("https://api.twitch.tv/kraken/users/" + username + "/follows/channels/" + channel + "?oauth_token=" + authToken.value, function(data) {
                            if(data)
                                followed = true
                        })
                    } else {
                        HTTP.deleteRequest("https://api.twitch.tv/kraken/users/" + username + "/follows/channels/" + channel + "?oauth_token=" + authToken.value, function(data) {
                            if(data === 204)
                                followed = false
                        })
                    }
                }
            },

            Action {
                iconName: "settings"
                name: qsTr("Quality")
                onTriggered: {
                    pageStack.push(streamSettings, { chatOnly: chatMode, audioOnly: audioMode, channel: channel })
                }
            }
        ]
    }

    QualityChooserPage {
        id: streamSettings
        onAccepted: {
            chatMode = chatOnly
            audioMode = audioOnly
            console.log("Chat mode", chatMode)
            console.log("Audio mode", audioMode)
        }
    }

    Timer {
        id: fullscreenTimer

        interval: 3000
        running: fullscreenConditions
        onTriggered: page.state = "fullscreen"
    }

    Flickable {
        id: main

        anchors.fill: parent
        contentHeight: isPortrait ? page.height : (chatMode ? page.height : (5/3 * page.height))
        //onContentHeightChanged: console.log(contentHeight, height + Screen.width, Screen.width, chat.height)

//        PullDownMenu {
//            id: streamMenu

//            MenuItem {
//                text: qsTr("Follow")
//                onClicked: HTTP.putRequest("https://api.twitch.tv/kraken/users/" + username + "/follows/channels/" + channel + "?oauth_token=" + authToken.value, function(data) {
//                    if(data)
//                        followed = true
//                })
//                visible: mainWindow.username && !followed
//            }

//            MenuItem {
//                text: qsTr("Unfollow")
//                onClicked: HTTP.deleteRequest("https://api.twitch.tv/kraken/users/" + username + "/follows/channels/" + channel + "?oauth_token=" + authToken.value, function(data) {
//                    if(data === 204)
//                        followed = false
//                })
//                visible: mainWindow.username && followed
//            }

//            MenuItem {
//                text: qsTr("Quality")
//                onClicked: {
//                    var dialog = pageStack.push(Qt.resolvedUrl("QualityChooserPage.qml"), { chatOnly: chatMode, audioOnly: audioMode, channel: channel })
//                    dialog.accepted.connect(function() {
//                        chatMode = dialog.chatOnly
//                        audioMode = dialog.audioOnly
//                    })
//                }
//            }
//        }

        Rectangle {
            id: videoBackground

            color: "black"
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
            height: (!chatMode && !audioMode) ? (page.width * 9/16) : 0
            visible: (!chatMode && !audioMode)

            Video {
                id: video

                anchors.fill: parent
                source: audioMode ? url["audio"] : url[streamQuality.value]

                onErrorChanged: console.error("video error:", errorString)

                ActivityIndicator {
                    anchors.centerIn: parent
                    running: video.playbackState !== MediaPlayer.PlayingState
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        page.state = !page.state ? "fullscreen" : ""
                        console.log(page.state)
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
                topMargin: chatMode ? Theme.paddingLarge : Theme.paddingMedium
                bottomMargin: Theme.paddingMedium
            }
            // Maybe it's better to replace ternary operators with if else blocks
            placeholderText: twitchChat.connected ? (twitchChat.anonymous ? qsTr("Please log in to send messages") : qsTr("Type your message here")) : qsTr("Chat is not available")
            enabled: twitchChat.connected && !twitchChat.anonymous
            inputMask: "X"
            onAccepted: {
                twitchChat.sendMessage(text)
                text = ""
            }
        }

        ListView {
            id: chat

            anchors {
                left: parent.left
                right: parent.right
                top: chatFlowBtT.value ? chatMessage.bottom : videoBackground.bottom
                bottom: chatFlowBtT.value ? parent.bottom : chatMessage.top
                //topMargin: (chatMode && !chatFlowBtT.value) ? 0 : Theme.paddingMedium
                //bottomMargin: 0//chatFlowBtT.value ? Theme.paddingLarge : Theme.paddingMedium
            }

            highlightRangeMode: count > 0 ? ListView.StrictlyEnforceRange : ListView.NoHighlightRange
            //preferredHighlightBegin: chat.height - currentItem.height
            preferredHighlightEnd: chat.height
            clip: true
            verticalLayoutDirection: chatFlowBtT.value ? ListView.BottomToTop : ListView.TopToBottom

            model: twitchChat.messages
            delegate: Item {
                height: lbl.height
                width: chat.width

                ListView.onAdd: {
                    if(chat.currentIndex >= chat.count - 3) {
                        chat.currentIndex = chat.count - 1
                    }
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
                    color: isNotice ? UbuntuColors.orange : UbuntuColors.ash
                }
            }

            IrcChat {
                id: twitchChat

                name: mainWindow.username
                password: 'oauth:' + authToken.value
                anonymous: !mainWindow.username
                textSize: 14

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

//        PropertyChanges {
//            target: streamMenu
//            visible: false
//            active: false
//        }

        PropertyChanges {
            target: mainWindow
            // special flag only supported by Unity8/MIR so far that hides the shell's
            // top panel in Staged mode
            flags: Qt.Window | 0x00800000
        }
    }
}

/*
 * Copyright © 2015-2017, 2019 Andrew Penkrat
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
import Sailfish.Silica 1.0
import QTwitch.Models 0.1
import QTwitch.Api 0.1
import harbour.twitchtube.ircchat 1.0
import Nemo.KeepAlive 1.1

Page {
    id: page

    property alias channel: channelInfo.login
    property alias userId: channelInfo.userId
    property bool followed
    property bool showVideo: !quality.audioOnly && !quality.chatOnly
    property bool active: Qt.application.active && (status === PageStatus.Active || quality.expanded)
    property bool fullscreenConditions: isLandscape && flickable.visibleArea.yPosition === 0 && !flickable.moving && !state && showVideo

    allowedOrientations: Orientation.All

    onActiveChanged: {
        if(active) {
            if(showVideo) {
                mainWindow.startPlayback(quality.streamUrl)
            }
            if(!twitchChat.connected) {
                twitchChat.reopenSocket()
                twitchChat.join(channel)
            }
        }
        else {
            if(showVideo) {
                mainWindow.stopPlayback()
            }
            if(twitchChat.connected)
                twitchChat.disconnect()
        }
    }

    Binding {
        target: DisplayBlanking
        property: "preventBlanking"
        value: active && showVideo
    }

    Binding {
        target: mainWindow
        property: "showCategories"
        value: status !== PageStatus.Active && status !== PageStatus.Activating && !quality.expanded
    }

    UserInfo {
        id: channelInfo
    }

    Timer {
        id: fullscreenTimer

        interval: 3000
        running: fullscreenConditions
        onTriggered: page.state = "fullscreen"
    }

    InterfaceConfiguration {
        property bool connectToChat: true
    }

    SilicaFlickable {
        id: flickable

        anchors.fill: parent
        anchors.bottomMargin: quality.visibleSize
        clip: quality.expanded

        PullDownMenu {
            id: streamMenu

            MenuItem {
                text: qsTr("Past Broadcasts & Highlights")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ChannelPage.qml"), { channel: channel })
                }
            }

            MenuItem {
                text: qsTr("Quality")
                enabled: !quality.empty
                onClicked: {
                    quality.show()
                }
            }
        }

        Rectangle {
            id: video

            width: parent.width
            height: showVideo ? (isPortrait ? Screen.width * 9/16 : Screen.width) : 0
            visible: showVideo
            color: "black"

            VideoOutput {
                anchors.fill: parent
                source: mainWindow.player

                BusyIndicator {
                    anchors.centerIn: parent
                    running: mainWindow.player.status === MediaPlayer.NoMedia
                          || mainWindow.player.status === MediaPlayer.Loading
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

        /*
        Chat {
            id: chat
            chatModel: twitchChat.messages
            displayMessageField: twitchChat.anonymous
            connected: twitchChat.connected

            width: parent.width
            height: Math.max(page.height - video.height, page.height * 2/3)

            IrcChat {
                id: twitchChat

                password: 'oauth:' + authToken.value
                anonymous: Client.authorizationStatus !== Client.Authorized
                textSize: Theme.fontSizeMedium

                Component.onCompleted: {
//                    twitchChat.join(channel)
                }

                onErrorOccured: {
                    console.log("Chat error: ", errorDescription)
                }

                onConnectedChanged: {
                    console.log(connected)
                }
            }
        }
        */
    }

    QualityChooser {
        id: quality

        playlist.channel: channel

        onChatOnlyChanged: {
            if (chatOnly) {
                mainWindow.stopPlayback()
            } else {
                mainWindow.startPlayback(streamUrl)
            }
        }

        onStreamUrlChanged: {
            if (!chatOnly)
                mainWindow.startPlayback(streamUrl)
        }
    }

    states: State {
        name: "fullscreen"

//        PropertyChanges {
//            target: chat
//            visible: false
//        }

        PropertyChanges {
            target: streamMenu
            visible: false
            active: false
        }

        PropertyChanges {
            target: page
            showNavigationIndicator: false
            allowedOrientations: Orientation.LandscapeMask
        }
    }
}

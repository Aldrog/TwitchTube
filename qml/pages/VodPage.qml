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
import "../js/httphelper.js" as HTTP

Page {
    id: page

    property var urls
    property int vodId
    property var vodDetails
    property bool active: Qt.application.active
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
                console.log(list[i])
            }
        }
        console.log("Available qualities:", res.selectableQualities)
        return res
    }

    function loadVodInfo() {
        HTTP.getRequest("https://api.twitch.tv/api/vods/" + vodId + "/access_token?oauth_token=" + authToken.value, function (tokendata) {
            if (tokendata) {
                var token = JSON.parse(tokendata)
                HTTP.getRequest(encodeURI("https://usher.ttvnw.net/vod/" + vodId + ".m3u8?allow_source=true&" +
                                          "nauthsig=" + token.sig + "&nauth=" + token.token + "&p=" + Math.floor(Math.random() * 1e8)),
                                function (data, err) {
                    if (data) {
                        var videourls = data.split('\n')
                        urls = findUrls(videourls)
                        video.startPlayback()
                    } else {
                        if(err === 403) {
                            videoStatus.text = qsTr("You do not have access to this video")
                        }
                    }
                })
            }
        })
    }

    allowedOrientations: Orientation.All

    onStatusChanged: {
        if(status === PageStatus.Activating) {
            mainWindow.currentVodId = vodId
            mainWindow.cover = Qt.resolvedUrl("../cover/VodCover.qml")
            cpptools.setBlankingMode(false)
        }
        if(status === PageStatus.Deactivating) {
            if (_navigation === PageNavigation.Back) {
                mainWindow.cover = Qt.resolvedUrl("../cover/NavigationCover.qml")
            }
            cpptools.setBlankingMode(true)
        }
    }

    onActiveChanged: {
        if(page.status === PageStatus.Active) {
            if(active) {
                video.startPlayback()
            }
            else {
                video.stopPlayback()
            }
        }
    }

    Component.onCompleted: {
        loadVodInfo()
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
        contentHeight: videoBackground.height + Theme.paddingMedium +
                       infoContainer.height +
                       Theme.paddingLarge

        PullDownMenu {
            id: vodMenu

            MenuItem {
                text: qsTr("Quality")
                enabled: urls != null
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("QualityChooserPage.qml"), { qualities: urls, allowVideoDisable: false })
                    dialog.accepted.connect(function() {
                        video.checkSource()
                    })
                }
            }
        }

        Rectangle {
            id: videoBackground

            color: "black"
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
            height: isPortrait ? screen.width * 9/16 : screen.width

            Video {
                id: video

                function stopPlayback() {
                    stop()
                    source = ""
                }

                function startPlayback() {
                    source = urls[urls.selectableQualities[streamQuality.value < urls.selectableQualities.length ?
                                                           streamQuality.value : urls.selectableQualities.length - 1]
                                 ].url
                    play()
                }

                function checkSource() {
                    if(source !== urls[urls.selectableQualities[streamQuality.value < urls.selectableQualities.length ?
                                                                streamQuality.value : urls.selectableQualities.length - 1]
                                      ].url) {
                        stopPlayback()
                        startPlayback()
                    }
                }

                anchors.fill: parent

                onErrorChanged: console.error("video error:", errorString)
                visible: !videoStatus.visible

                onDurationChanged: timeline.maximumValue = duration

                BusyIndicator {
                    anchors.centerIn: parent
                    running: video.status === MediaPlayer.NoMedia
                          || video.status === MediaPlayer.Loading
                          || video.status === MediaPlayer.Stalled
                    size: isPortrait ? BusyIndicatorSize.Medium : BusyIndicatorSize.Large
                }
            }

            Label {
                id: videoStatus
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: Theme.secondaryColor
                visible: text !== ""
            }

            IconButton {
                id: playbackControlButton
                anchors {
                    left: parent.left
                    bottom: parent.bottom
                    leftMargin: Theme.paddingMedium
                    bottomMargin: Theme.paddingMedium
                }
                icon.source: video.playbackState === MediaPlayer.PlayingState ?
                                 "image://theme/icon-m-pause" : "image://theme/icon-m-play"

                onClicked: {
                    if(video.playbackState === MediaPlayer.PlayingState)
                        video.pause()
                    else
                        video.play()
                }
            }

            Slider {
                id: timeline
                anchors {
                    left: playbackControlButton.right
                    // IconButton and Slider both already include margins, so let's move them closer
                    leftMargin: -Theme.paddingMedium
                    right: parent.right
                    bottom: parent.bottom
                }
                enabled: video.seekable

                minimumValue: 0
                valueText: Format.formatDuration(value/1000, maximumValue/1000 > 3600 ? Format.DurationLong : Format.DurationShort)

                onReleased: video.seek(value)

                Binding on value{
                    when: !pressed
                    value: video.position
                }
            }

            MouseArea {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    bottom: timeline.top
                }

                onClicked: {
                    page.state = !page.state ? "fullscreen" : ""
                    console.log(page.state)
                }
            }
        }

        Column {
            id: infoContainer

            anchors {
                top: videoBackground.bottom
                left: parent.left
                right: parent.right
                leftMargin: Theme.horizontalPageMargin
                rightMargin: Theme.horizontalPageMargin
                topMargin: Theme.paddingMedium
            }

            spacing: Theme.paddingSmall

            Label {
                id: titleLabel
                width: parent.width
                wrapMode: Text.Wrap
                font.family: Theme.fontFamilyHeading
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.highlightColor
                text: vodDetails.title
            }

            Separator {
                visible: descriptionLabel.text !== ""
                width: parent.width
            }

            Label {
                id: descriptionLabel
                width: parent.width
                wrapMode: Text.Wrap
                text: vodDetails.description
            }
        }

        ScrollDecorator { flickable: main }
    }

    states: State {
        name: "fullscreen"
        PropertyChanges {
            target: main
            contentHeight: page.height
        }

        PropertyChanges {
            target: infoContainer
            visible: false
        }

        PropertyChanges {
            target: playbackControlButton
            visible: false
        }

        PropertyChanges {
            target: timeline
            visible: false
        }

        PropertyChanges {
            target: vodMenu
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

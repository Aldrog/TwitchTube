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
            }
        }
        console.log("Available qualities:", res.selectableQualities)
        return res
    }

    function loadVodInfo() {
        HTTP.getRequest("http://api.twitch.tv/api/vods/" + vodId + "/access_token?oauth_token=" + authToken.value, function (tokendata) {
            if (tokendata) {
                var token = JSON.parse(tokendata)
                HTTP.getRequest(encodeURI("http://usher.twitch.tv/vod/" + vodId + ".m3u8?allow_source=true&" +
                                          "sig=" + token.sig + "&token=" + token.token + "&p=" + Math.floor(Math.random() * 1e8)),
                                function (data, err) {
                    if (data) {
                        var videourls = data.split('\n')
                        urls = findUrls(videourls)
                        video.play()
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
                video.play()
            }
            else {
                video.pause()
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
                    pageStack.push(Qt.resolvedUrl("QualityChooserPage.qml"), { qualities: urls, allowVideoDisable: true })
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

                anchors.fill: parent
                source: urls[urls.selectableQualities[streamQuality.value < urls.selectableQualities.length ?
                                                      streamQuality.value : urls.selectableQualities.length - 1]
                            ].url

                onErrorChanged: console.error("video error:", errorString)
                visible: !videoStatus.visible

                BusyIndicator {
                    anchors.centerIn: parent
                    running: video.playbackState !== MediaPlayer.PlayingState
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

            MouseArea {
                anchors.fill: parent
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

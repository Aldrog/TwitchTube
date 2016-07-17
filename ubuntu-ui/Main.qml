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
import "pages"
import "js/httphelper.js" as HTTP

MainView {
    id: mainWindow

    property string username

    signal userChanged

    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "twitchtube.aldrog"

    width: units.gu(100)
    height: units.gu(75)

    Component.onCompleted: {
        if(authToken.value) {
            HTTP.getRequest("https://api.twitch.tv/kraken/user?oauth_token=" + authToken.value, function(data) {
                if(data) {
                    var user = JSON.parse(data)
                    username = user.name
                    console.log("Successfully received username")
                }
            })
        }

        pageStack.push(startingPage)
    }

    PageStack {
        id: pageStack
    }

    GamesPage {
        id: startingPage
        visible: false
    }
}

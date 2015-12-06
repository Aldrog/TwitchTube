/*
 * Copyright © 2015 Andrew Penkrat
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
import "pages"
import "js/httphelper.js" as HTTP

ApplicationWindow
{
    id: mainWindow

    property string currentChannel
    property string username

    initialPage: Component { GamesPage { } }
    cover: Qt.resolvedUrl("cover/NavigationCover.qml")

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
    }
}

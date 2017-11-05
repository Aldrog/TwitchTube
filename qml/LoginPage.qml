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

Page {
    id: page

    // Status for NavigationCover
    property string navStatus: qsTr("Settings")

    title: qsTr("Log into Twitch account")
    addPadding: false

    WebView {
        id: twitchLogin

        width: page.width
        height: page.height - page.header.height

        onNavigationRequested: {
            var url = request.url.toString()
            if(url.indexOf("http://localhost") === 0) {
                var params = url.substring(url.lastIndexOf('/') + 1)
                if(params.indexOf("#access_token") >= 0) {
                    authToken.value = params.split('=')[1].split('&')[0]
                }
                page.forcePop()
            }
            else
                accept(request)
        }
        url: encodeURI("https://api.twitch.tv/kraken/oauth2/authorize?response_type=token&client_id=n57dx0ypqy48ogn1ac08buvoe13bnsu&redirect_uri=http://localhost&scope=user_read user_follows_edit chat_login")
    }
}

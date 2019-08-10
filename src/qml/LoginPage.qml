/*
 * Copyright © 2015-2017, 2019 Andrew Penkrat <contact.aldrog@gmail.com>
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

import QtQuick 2.6
import Sailfish.Silica 1.0
import QtWebKit 3.0
import QTwitch.Api 0.1

Page {
    id: page

    property bool aboutToPop: false

    function forcePop() {
        if(status === PageStatus.Activating)
            aboutToPop = true
        else
            pageStack.pop()
    }

    onStatusChanged: {
        if(status === PageStatus.Active && aboutToPop)
            pageStack.pop()
    }

    PageHeader {
        id: head
        title: qsTr("Sign in with Twitch")
    }

    WebView {
        id: twitchLogin

        anchors {
            top: head.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        onNavigationRequested: {
            var url = request.url.toString()
            if(url.indexOf("http://localhost") === 0) {
                Client.authorization.update(url)
                page.forcePop()
            }
            else
                request.action = WebView.AcceptRequest
        }
        url: Client.authorization.init([ Authorization.UserFollowsEdit,
                                         Authorization.ChatRead,
                                         Authorization.ChatEdit ], true)
    }
}

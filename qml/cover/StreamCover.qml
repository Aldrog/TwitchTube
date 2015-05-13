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

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/httphelper.js" as HTTP

CoverBackground {
	id: root

	property string channel: pageStack.currentPage.channel
//	property string streamStatus

	Image {
		id: streamPreview
		anchors.fill: parent
		fillMode: Image.PreserveAspectCrop
		opacity: 0.5
	}

//	Label {
//		id: statusLabel
//		anchors.centerIn: parent
//		width: parent.width
//		wrapMode: Text.WordWrap
//		horizontalAlignment: Text.AlignHCenter
//	}

	CoverPlaceholder {
		id: statusContainer
		icon.opacity: 0.7
		icon.source: "../images/icon.png"
	}

	Component.onCompleted: {
		HTTP.getRequest("https://api.twitch.tv/kraken/streams/" + channel, function(data) {
			if(data) {
				var stream = JSON.parse(data).stream
				streamPreview.source = stream.preview.template.replace("{height}", root.height).replace("{width}", ~~(root.height*16/9))
				statusContainer.text = stream.channel.status
			}
		})
	}
}

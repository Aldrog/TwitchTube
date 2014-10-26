/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: page

	property var streams
	function getStreams() {
		var request = new XMLHttpRequest()
		request.open('GET', 'https://api.twitch.tv/kraken/streams')
		request.onreadystatechange = function() {
			if (request.readyState === XMLHttpRequest.DONE) {
				if (request.status && request.status === 200) {
					//console.log("response", request.responseText)
					var result = JSON.parse(request.responseText)
					for (var i in result.streams[1].preview)
						console.log(i)
					page.streams = result.streams
				} else {
					console.log("HTTPS:", request.status, request.statusText)
				}
			}
		}
		request.send()
	}

	SilicaGridView {
		id: gridChannels
		model: streams
		anchors.fill: parent
		cellWidth: width/2
		cellHeight: cellWidth*5/8
		header: PageHeader {
			title: qsTr("Live Channels")
		}
		delegate: BackgroundItem {
			id: delegate
			contentWidth: gridChannels.cellWidth
			contentHeight: gridChannels.cellHeight
			Image {
				id: preview
				source: modelData.preview.medium
				anchors.fill: parent
			}
			Label {
				anchors.left: parent.left; anchors.leftMargin: Theme.paddingLarge
				anchors.right: parent.right; anchors.rightMargin: Theme.paddingLarge
				text: modelData.channel.display_name
				truncationMode: TruncationMode.Fade
				color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
			}
			onClicked: pageStack.push(Qt.resolvedUrl("StreamPage.qml"))
		}
		VerticalScrollDecorator {}
	}

	Component.onCompleted: {
		getStreams()
	}
}






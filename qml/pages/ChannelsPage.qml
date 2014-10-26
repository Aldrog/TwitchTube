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
			width: gridChannels.cellWidth
			height: gridChannels.cellHeight
			onClicked: pageStack.push(Qt.resolvedUrl("StreamPage.qml"))
			Image {
				id: preview
				source: modelData.preview.medium
				anchors {
					fill: parent
					leftMargin: Theme.paddingSmall
					rightMargin: Theme.paddingSmall
					topMargin: Theme.paddingSmall
					bottomMargin: Theme.paddingSmall
				}
			}
			Label {
				anchors {
					left: parent.left; leftMargin: Theme.paddingLarge
					right: parent.right; rightMargin: Theme.paddingLarge
				}
				text: modelData.channel.display_name
				truncationMode: TruncationMode.Fade
				color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
			}
		}
		VerticalScrollDecorator {}
	}

	Component.onCompleted: {
		getStreams()
	}
}






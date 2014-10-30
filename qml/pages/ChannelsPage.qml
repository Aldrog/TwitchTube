import QtQuick 2.0
import Sailfish.Silica 1.0
import 'scripts/httphelper.js' as HTTP


Page {
	id: page
	allowedOrientations: Orientation.All

	property var streams
	property int row: isPortrait ? 2 : 3

	SilicaGridView {
		id: gridChannels

		PullDownMenu {
			MenuItem {
				text: qsTr("Games")
				onClicked: pageStack.replaceAbove(null, Qt.resolvedUrl("GamesPage.qml"))
			}
		}

		model: streams
		anchors.fill: parent
		cellWidth: width/row
		cellHeight: cellWidth*5/8
		header: PageHeader {
			title: qsTr("Live Channels")
		}
		delegate: BackgroundItem {
			id: delegate
			width: gridChannels.cellWidth
			height: gridChannels.cellHeight
			onClicked: pageStack.push (Qt.resolvedUrl("StreamPage.qml"), { channel: modelData.channel.name })
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

		VerticalScrollDecorator { flickable: gridChannels }
	}

	Component.onCompleted: {
		HTTP.getRequest("https://api.twitch.tv/kraken/streams",function(data) {
			if (data)
				streams = JSON.parse(data).streams
		})
	}
}






import QtQuick 2.0
import Sailfish.Silica 1.0
import 'scripts/httphelper.js' as HTTP


Page {
	id: page
	allowedOrientations: Orientation.All

	property bool bygame: false
	property string game
	property var streams
	property int row: isPortrait ? 2 : 3

	SilicaGridView {
		id: gridChannels
		anchors.fill: parent

		PullDownMenu {
			MenuItem {
				text: qsTr("Games")
				onClicked: pageStack.replaceAbove(null, Qt.resolvedUrl("GamesPage.qml"))
			}
		}

		model: streams
		cellWidth: width/row
		cellHeight: cellWidth*5/8

		header: PageHeader {
			title: bygame ? game : qsTr("Live Channels")
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
				id: name
				anchors {
					left: parent.left; leftMargin: Theme.paddingLarge
					right: parent.right; rightMargin: Theme.paddingLarge
					topMargin: Theme.paddingSmall
				}
				text: modelData.channel.display_name
				truncationMode: TruncationMode.Fade
				color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
			}
		}

		VerticalScrollDecorator { flickable: gridChannels }
	}

	Component.onCompleted: {
		var url = "https://api.twitch.tv/kraken/streams"
		if (bygame)
			url += encodeURI("?game=" + game)
		HTTP.getRequest(url,function(data) {
			if (data)
				streams = JSON.parse(data).streams
		})
	}
}






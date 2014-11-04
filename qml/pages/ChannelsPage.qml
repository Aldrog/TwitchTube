import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0
import "scripts/httphelper.js" as HTTP


Page {
	id: page
	allowedOrientations: Orientation.All

	property bool bygame: false
	property string game
	property int row: isPortrait ? 2 : 3
	//in brackets should be row lengths for portrait and landscape orientations
	property int countOnPage: (2*3)*2
	property string nextlink

	ConfigurationValue {
		id: previewSize
		key: "/apps/twitch/settings/gameimgsize"
		defaultValue: "large"
	}

	SilicaGridView {
		id: gridChannels
		anchors.fill: parent

		PullDownMenu {
			MenuItem {
				text: qsTr("Settings")
				onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
			}

			MenuItem {
				text: qsTr("Search")
			}

			MenuItem {
				text: qsTr("Following")
			}

			MenuItem {
				text: qsTr("Games")
				onClicked: pageStack.replaceAbove(null, Qt.resolvedUrl("GamesPage.qml"))
				visible: !bygame
			}

			MenuItem {
				text: qsTr("Channels")
				onClicked: pageStack.replaceAbove(null, Qt.resolvedUrl("ChannelsPage.qml"))
				visible: bygame
			}
		}

		PushUpMenu {
			MenuItem {
				text: qsTr("Load more")
				onClicked: {
					HTTP.getRequest(nextlink,function(data) {
						if (data) {
							var result = JSON.parse(data)
							nextlink = result._links.next
							for (var i in result.streams)
								streamList.append(result.streams[i])
						}
					})
				}
			}
		}

		model: ListModel { id: streamList }
		cellWidth: width/row
		cellHeight: cellWidth*5/8

		header: PageHeader {
			title: bygame ? game : qsTr("Live Channels")
		}

		delegate: BackgroundItem {
			id: delegate
			width: gridChannels.cellWidth
			height: gridChannels.cellHeight
			onClicked: pageStack.push (Qt.resolvedUrl("StreamPage.qml"), { channel: channel.name })

			Image {
				id: previewImage
				source: preview[previewSize.value]
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
				text: channel.display_name
				truncationMode: TruncationMode.Fade
				color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
			}
		}

		VerticalScrollDecorator { flickable: gridChannels }
	}

	Component.onCompleted: {
		var url = "https://api.twitch.tv/kraken/streams?limit=" + countOnPage
		if (bygame)
			url += encodeURI("&game=" + game)
		console.log(url)
		HTTP.getRequest(url,function(data) {
			if (data) {
				var result = JSON.parse(data)
				nextlink = result._links.next
				for (var i in result.streams)
					streamList.append(result.streams[i])
			}
		})
	}
}






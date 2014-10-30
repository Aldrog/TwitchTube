import QtQuick 2.0
import Sailfish.Silica 1.0
import 'scripts/httphelper.js' as HTTP


Page {
	id: page
	allowedOrientations: Orientation.All

	property var games
	property int row: isPortrait ? 2 : 4

	SilicaGridView {
		id: gridGames
		anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Channels")
                onClicked: pageStack.replaceAbove(null, Qt.resolvedUrl("ChannelsPage.qml"))
            }
        }

		model: games
		cellWidth: width/row
		cellHeight: cellWidth*18/13

		header: PageHeader {
			title: qsTr("Popular Games")
		}

		delegate: BackgroundItem {
			id: delegate
			width: gridGames.cellWidth
			height: gridGames.cellHeight
			onClicked: pageStack.push (Qt.resolvedUrl("ChannelsPage.qml"),{ bygame: true, game: modelData.game.name })

			Image {
				id: logo
				fillMode: Image.PreserveAspectCrop
				source: modelData.game.box.large
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
				font.pixelSize: Theme.fontSizeSmall
				anchors {
					left: parent.left; leftMargin: Theme.paddingLarge
					right: parent.right; rightMargin: Theme.paddingLarge
					topMargin: Theme.paddingSmall
				}
				text: modelData.game.name
				truncationMode: TruncationMode.Fade
				color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
			}
        }

		VerticalScrollDecorator { flickable: gridGames }
    }

	Component.onCompleted: {
		HTTP.getRequest("https://api.twitch.tv/kraken/games/top", function (data) {
			if (data) {
				games = JSON.parse(data).top
			}
		})
	}
}



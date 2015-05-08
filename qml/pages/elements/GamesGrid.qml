import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0

SilicaGridView {
	id: root
	anchors.fill: parent
	property int row: isPortrait ? 2 : 4
	// In brackets must be row lengths for portrait and landscape orientations
	property int countOnPage: (2*4) * 2
	property int offset: 0
	property int totalCount: 0
	property bool autoLoad: true

	ConfigurationValue {
		id: posterSize
		key: "/apps/twitch/settings/gameimgsize"
		defaultValue: "large"
	}

	PushUpMenu {
		enabled: offset < totalCount
		visible: offset < totalCount

		MenuItem {
			text: qsTr("Load more")
			onClicked: {
				loadGames()
			}
		}
	}

	model: ListModel { id: gameList }
	cellWidth: width/row
	// 18:13 is the actual aspect ratio of previews
	cellHeight: cellWidth * 18/13

	delegate: BackgroundItem {
		id: delegate
		width: root.cellWidth
		height: root.cellHeight
		onClicked: pageStack.push (Qt.resolvedUrl("../GameChannelsPage.qml"),{ game: game.name })

		Image {
			id: logo
			anchors.fill: parent
			anchors.margins: Theme.paddingSmall
			fillMode: Image.PreserveAspectCrop
			source: game.box[posterSize.value]
		}

		OpacityRampEffect {
			sourceItem: logo
			direction: OpacityRamp.BottomToTop
			offset: 0.75
			slope: 4.0
		}

		Label {
			id: name
			anchors {
				left: parent.left; leftMargin: Theme.paddingLarge
				right: parent.right; rightMargin: Theme.paddingLarge
				topMargin: Theme.paddingMedium
			}
			text: game.name
			truncationMode: TruncationMode.Fade
			color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
			font.pixelSize: Theme.fontSizeSmall
		}
	}

	VerticalScrollDecorator { flickable: root }

	Component.onCompleted: {
		if(autoLoad)
			loadGames()
	}
}

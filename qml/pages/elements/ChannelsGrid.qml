import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0

SilicaGridView {
	id: root
	anchors.fill: parent
	property int row: isPortrait ? 2 : 3
	// In brackets must be row lengths for portrait and landscape orientations
	property int countOnPage: (2*3) * 3
	property int offset: 0
	property int totalCount: 0
	property bool autoLoad: true

	ConfigurationValue {
		id: previewSize
		key: "/apps/twitch/settings/previewimgsize"
		defaultValue: "medium"
	}

	PushUpMenu {
		enabled: offset < totalCount
		visible: offset < totalCount

		MenuItem {
			text: qsTr("Load more")
			onClicked: {
				loadChannels()
			}
		}
	}

	model: ListModel { id: channelsList }
	cellWidth: width/row
	// 5:8 is the actual aspect ratio of previews
	cellHeight: cellWidth * 5/8

	delegate: BackgroundItem {
		id: delegate
		width: root.cellWidth
		height: root.cellHeight
		onClicked: pageStack.push (Qt.resolvedUrl("StreamPage.qml"), { channel: channel.name })

		Image {
			id: previewImage
			source: preview[previewSize.value]
			anchors.fill: parent
			anchors.margins: Theme.paddingSmall
		}

		OpacityRampEffect {
			sourceItem: previewImage
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
			text: channel.display_name
			truncationMode: TruncationMode.Fade
			color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
			font.pixelSize: Theme.fontSizeSmall
		}
	}

	VerticalScrollDecorator { flickable: root }

	Component.onCompleted: {
		if(autoLoad)
			loadChannels()
	}
}

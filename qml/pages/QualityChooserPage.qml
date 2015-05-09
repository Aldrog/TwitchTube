import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
	id: page
	allowedOrientations: Orientation.All

	property var qualities: ["chunked", "high", "medium", "low", "mobile"]
	property bool chatOnly

	property string streamQuality: qmlSettings.value("Video/StreamQuality", "medium", qmlSettings.change)

	Column {
		anchors.fill: parent

		DialogHeader {
			id: head
			title: qsTr("Set up stream quality")
		}

		ComboBox {
			id: qualityChooser
			width: parent.width
			label: qsTr("Stream quality")
			currentIndex: qualities.indexOf(streamQuality)

			menu: ContextMenu {
				MenuItem { text: qsTr("Source") }
				MenuItem { text: qsTr("High") }
				MenuItem { text: qsTr("Medium") }
				MenuItem { text: qsTr("Low") }
				MenuItem { text: qsTr("Mobile") }
			}
		}

		TextSwitch {
			id: noVideo
			checked: chatOnly
			text: "Chat only"
		}
	}

	onAccepted: {
		qmlSettings.setValue("Video/StreamQuality", qualities[qualityChooser.currentIndex])
		chatOnly = noVideo.checked
	}
}

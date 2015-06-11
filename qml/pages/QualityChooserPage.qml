import QtQuick 2.1
import Sailfish.Silica 1.0

Dialog {
	id: page
	allowedOrientations: Orientation.All

	property var qualities: ["chunked", "high", "medium", "low", "mobile"]
	property bool chatOnly

	SilicaFlickable {
		anchors.fill: parent
		contentHeight: head.height + optionsContainer.height

		DialogHeader {
			id: head
			title: qsTr("Set up stream quality")
		}

		Column {
			id: optionsContainer
			anchors.top: head.bottom
			width: page.width

			ComboBox {
				id: qualityChooser
				width: parent.width
				label: qsTr("Stream quality")
				currentIndex: qualities.indexOf(streamQuality.value)

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
	}

	onAccepted: {
		streamQuality.value = qualities[qualityChooser.currentIndex]
		chatOnly = noVideo.checked
	}
}

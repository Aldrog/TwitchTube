import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0

Dialog {
	id: page

	property var imageSizes: ["large", "medium", "small"]

	ConfigurationValue {
		id: gameImageSize
		key: "/apps/twitch/settings/gameimgsize"
		defaultValue: "large"
	}

	ConfigurationValue {
		id: previewImageSize
		key: "/apps/twitch/settings/previewimgsize"
		defaultValue: "medium"
	}

	Column {
		id: settings
		anchors.fill: parent

		DialogHeader {
			title: qsTr("Twitch Settings")
			acceptText: qsTr("Apply")
		}

		ComboBox {
			id: gameQ
			label: qsTr("Game posters quality")
			menu: ContextMenu {
				MenuItem { text: qsTr("High") }
				MenuItem { text: qsTr("Medium") }
				MenuItem { text: qsTr("Low") }
			}
			currentIndex: imageSizes.indexOf(gameImageSize.value)
		}

		ComboBox {
			id: previewQ
			label: qsTr("Stream previews quality")
			menu: ContextMenu {
				MenuItem { text: qsTr("High") }
				MenuItem { text: qsTr("Medium") }
				MenuItem { text: qsTr("Low") }
			}
			currentIndex: imageSizes.indexOf(previewImageSize.value)
		}
		//Uncomment this when there will be more settings
		//VerticalScrollDecorator { flickable: settings }
	}

	onAccepted: {
		gameImageSize.value = imageSizes[gameQ.currentIndex]
		previewImageSize.value = imageSizes[previewQ.currentIndex]
	}
}

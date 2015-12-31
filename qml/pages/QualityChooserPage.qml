import QtQuick 2.1
import Sailfish.Silica 1.0

Dialog {
    id: page

    property var qualities: ["chunked", "high", "medium", "low", "mobile"]
    property bool chatOnly
    property bool audioOnly

    allowedOrientations: Orientation.All

    onAccepted: {
        streamQuality.value = qualities[qualityChooser.currentIndex]
        chatOnly = chatOnlySwitch.checked
        audioOnly = audioOnlySwitch.checked
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: header.height + optionsContainer.height

        DialogHeader {
            id: header
            title: qsTr("Stream properties")
        }

        Column {
            id: optionsContainer

            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
            }

            ComboBox {
                id: qualityChooser

                width: parent.width
                label: qsTr("Quality")
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
                id: chatOnlySwitch
                checked: chatOnly
                text: qsTr("Chat only")

                onCheckedChanged: {
                    if(checked)
                        audioOnlySwitch.checked = false
                }
            }

            TextSwitch {
                id: audioOnlySwitch
                checked: audioOnly
                text: qsTr("Audio only")

                onCheckedChanged: {
                    if(checked)
                        chatOnlySwitch.checked = false
                }
            }
        }
    }
}

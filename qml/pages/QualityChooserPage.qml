import QtQuick 2.1
import Sailfish.Silica 1.0

Dialog {
    id: page

    property var qualities

    // Set to false to forbid audio and chat only modes
    property bool allowVideoDisable: true

    property bool chatOnly
    property bool audioOnly

    allowedOrientations: Orientation.All

    Component.onCompleted: console.log(allowVideoDisable)

    onAccepted: {
        streamQuality.value = qualityChooser.currentIndex
        if(allowVideoDisable) {
            chatOnly = chatOnlySwitch.checked
            audioOnly = audioOnlySwitch.checked
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: header.height + optionsContainer.height

        DialogHeader {
            id: header
            title: qsTr("Playback options")
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
                currentIndex: streamQuality.value < qualities.selectableQualities.length ? streamQuality.value : (qualities.selectableQualities.length - 1)

                menu: ContextMenu {
                    Repeater {
                        model: qualities.selectableQualities
                        delegate: MenuItem { text: qualities[modelData].name }
                    }
                }
            }

            TextSwitch {
                id: chatOnlySwitch
                checked: chatOnly
                text: qsTr("Chat only")
                visible: allowVideoDisable

                onCheckedChanged: {
                    if(checked)
                        audioOnlySwitch.checked = false
                }
            }

            TextSwitch {
                id: audioOnlySwitch
                checked: audioOnly
                text: qsTr("Audio only")
                visible: allowVideoDisable

                onCheckedChanged: {
                    if(checked)
                        chatOnlySwitch.checked = false
                }
            }
        }
    }
}

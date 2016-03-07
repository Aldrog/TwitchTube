import QtQuick 2.1
import Sailfish.Silica 1.0

SilicaFlickable {
    id: root

    property alias grids: container.data
    property alias header: mainHeader

    anchors.fill: parent
    contentHeight: container.height + Theme.paddingLarge - (header.visible ? 0 : header.height)

    Column {
        id: container
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.rightMargin: Theme.horizontalPageMargin
        anchors.bottomMargin: Theme.paddingLarge

        PageHeader {
            id: mainHeader
        }
    }

    PushUpMenu {
        id: loadMoreMenu
        enabled: grids[grids.length - 1].offset < grids[grids.length - 1].totalCount
        visible: grids[grids.length - 1].offset < grids[grids.length - 1].totalCount

        MenuItem {
            text: qsTr("Load more")
            onClicked: {
                grids[grids.length - 1].loadContent()
            }
        }
    }

    VerticalScrollDecorator { flickable: root }
}

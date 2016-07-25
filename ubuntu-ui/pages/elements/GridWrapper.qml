import QtQuick 2.4
import Ubuntu.Components 1.3

Flickable {
    id: root

    property alias grids: container.data
    //property alias header: mainHeader

    anchors.fill: parent
    contentHeight: container.height

    Column {
        id: container
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: units.gu(2)
        anchors.rightMargin: units.gu(2)

//        PageHeader {
//            id: mainHeader
//        }
    }

//    PushUpMenu {
//        id: loadMoreMenu
//        enabled: grids[grids.length - 1].offset < grids[grids.length - 1].totalCount
//        visible: grids[grids.length - 1].offset < grids[grids.length - 1].totalCount

//        MenuItem {
//            text: qsTr("Load more")
//            onClicked: {
//                grids[grids.length - 1].loadContent()
//            }
//        }
//    }
}

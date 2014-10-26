import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
	Text {
        id: label
        anchors.centerIn: parent
		horizontalAlignment: Text.AlignHCenter
		text: qsTr("TODO: \nPrint current \nstream name here")
    }

    //I dont't think twitch needs actions on cover
//    CoverActionList {
//        id: coverAction

//        CoverAction {
//            iconSource: "image://theme/icon-cover-next"
//        }

//        CoverAction {
//            iconSource: "image://theme/icon-cover-pause"
//        }
//    }
}



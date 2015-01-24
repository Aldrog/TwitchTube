import QtQuick 2.0
import Sailfish.Silica 1.0

PullDownMenu {
	property bool search: true
	property bool following: true
	property bool channels: true
	property bool games: true

	MenuItem {
		text: qsTr("Settings")
		onClicked: pageStack.push(Qt.resolvedUrl("../SettingsPage.qml"))
	}

	MenuItem {
		text: qsTr("Search")
		onClicked: pageStack.replaceAbove(null, Qt.resolvedUrl("../SearchPage.qml"))
		visible: search
	}

	MenuItem {
		text: qsTr("Following")
		onClicked: pageStack.replaceAbove(null, Qt.resolvedUrl("../FollowedPage.qml"))
		visible: following
	}

	MenuItem {
		text: qsTr("Channels")
		onClicked: pageStack.replaceAbove(null, Qt.resolvedUrl("../ChannelsPage.qml"))
		visible: channels
	}

	MenuItem {
		text: qsTr("Games")
		onClicked: pageStack.replaceAbove(null, Qt.resolvedUrl("../GamesPage.qml"))
		visible: games
	}
}

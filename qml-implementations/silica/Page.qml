/*
 * Copyright © 2017 Andrew Penkrat
 *
 * This file is part of TwitchTube.
 *
 * TwitchTube is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * TwitchTube is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with TwitchTube.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.1
import Sailfish.Silica 1.0

Page {
    id: page

    property alias title: header.title
    property alias headerContent: headerContainer.data
    default property alias data: pageContent.data
    property alias flickable: rootFlickable
    property alias header: header

    property list<Action> actions

    readonly property int landscapeOrientation: Orientation.Landscape | Orientation.LandscapeInverted
    readonly property int portraitOrientation:  Orientation.Portrait  | Orientation.PortraitInverted
    property bool addPadding: true

    readonly property bool aboutToPop: false

    signal opened()
    signal closed()

    function forcePop() {
        if(status === PageStatus.Activating)
            aboutToPop = true
        else
            pageStack.pop()
    }

    allowedOrientations: Orientation.All

    onStatusChanged: {
        if(status === PageStatus.Active) {
            opened()
        }
        if(status === PageStatus.Deactivating) {
            if (_navigation === PageNavigation.Back) {
                closed()
            }
        }

        if(status === PageStatus.Active && aboutToPop)
            pageStack.pop()
    }

    SilicaFlickable {
        id: rootFlickable
        anchors.fill: parent
        contentHeight: pageContent.implicitHeight + (addPadding ? Theme.paddingLarge : 0)

        Loader {
            active: actions.length > 0

            sourceComponent: PullDownMenu {
                id: contextMenu

                Repeater {
                    model: actions.length
                    delegate: MenuItem {
                        text: actions[index].text
                        visible: actions[index].visible
                        enabled: actions[index].visible

                        onClicked: actions[index].triggered()
                    }
                }
            }
        }

        Column {
            id: pageContent
            width: parent.width

            PageHeader {
                id: header
                rightMargin: Theme.horizontalPageMargin + (headerContainer.width > 0 ? headerContainer.width + Theme.paddingMedium : 0)
                visible: title

                Row {
                    id: headerContainer
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.horizontalPageMargin
                    height: Theme.itemSizeSmall - (isPortrait ? 0 : Theme.paddingSmall)
                }
            }
        }

        VerticalScrollDecorator { flickable: rootFlickable }
    }
}

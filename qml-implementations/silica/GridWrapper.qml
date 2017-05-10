/*
 * Copyright © 2016-2017 Andrew Penkrat
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

SilicaFlickable {
    id: root

    property alias grids: container.data
    property alias header: mainHeader
    property int gridsShown: 2

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
        id: loadGridMenu
        enabled: gridsShown < grids.length || grids[gridsShown - 1].offset < grids[gridsShown - 1].totalCount
        visible: gridsShown < grids.length || grids[gridsShown - 1].offset < grids[gridsShown - 1].totalCount

        MenuItem {
            id: loadMoreOption

            text: root.grids[gridsShown - 1].offset < root.grids[gridsShown - 1].totalCount ?
                      qsTr("Load more") :
                      (grids[gridsShown] ? grids[gridsShown].loadText : "")
            onClicked: {
                if(root.grids[gridsShown - 1].offset < root.grids[gridsShown - 1].totalCount)
                    grids[gridsShown - 1].loadContent()
                else {
                    grids[gridsShown].visible = true
                    grids[gridsShown].loadContent()
                    gridsShown++
                }
            }
        }
    }

    VerticalScrollDecorator { flickable: root }
}

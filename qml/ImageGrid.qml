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
import "implementation"

Grid {
    id: grid

    property int rowSize
    property int pageSize
    property real aspectRatio
    property bool autoLoad: true
    property bool showSubtitles: false
    property var imageIndex
    property alias model: content.model
    property alias delegate: content.delegate

    property int offset: 0
    property int totalCount: 0

    signal clicked(var item)

    Component.onCompleted: {
        if(autoLoad)
            loadContent()
    }

    columns: rowSize
    width: parent.width

    Repeater {
        id: content

        model: ListModel { }
        delegate: ImageItem {
            width: grid.width/rowSize
            height: width * aspectRatio
            imageSource: imageIndex ? model.images[imageIndex] : model.image
            title: model.title
            subtitle: showSubtitles ? model.subtitle : ""

            onClicked: {
                grid.clicked(model)
            }
        }
    }
}

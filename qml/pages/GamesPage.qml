import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0
import "scripts/httphelper.js" as HTTP


Page {
	id: page
	allowedOrientations: Orientation.All

	property int row: isPortrait ? 2 : 4
	//in brackets should be row lengths for portrait and landscape orientations
	property int countOnPage: (2*4)*2
	property string nextlink

	ConfigurationValue {
		id: posterSize
		key: "/apps/twitch/settings/gameimgsize"
		defaultValue: "medium"
	}

	SilicaGridView {
		id: gridGames
		anchors.fill: parent

		PullDownMenu {
			MenuItem {
				text: qsTr("Settings")
				onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
			}

			MenuItem {
				text: qsTr("Search")
				onClicked: pageStack.replaceAbove(null, Qt.resolvedUrl("SearchPage.qml"))
			}

			MenuItem {
				text: qsTr("Following")
			}

            MenuItem {
                text: qsTr("Channels")
                onClicked: pageStack.replaceAbove(null, Qt.resolvedUrl("ChannelsPage.qml"))
			}
		}

		PushUpMenu {
			MenuItem {
				text: qsTr("Load more")
				onClicked: {
					HTTP.getRequest(nextlink,function(data) {
						if (data) {
							var result = JSON.parse(data)
							nextlink = result._links.next
							for (var i in result.top)
								gameList.append(result.top[i])
						}
					})
				}
			}
		}

		header: PageHeader {
			title: qsTr("Popular Games")
		}

		model: ListModel { id: gameList }
		cellWidth: width/row
		cellHeight: cellWidth*18/13

		delegate: BackgroundItem {
			id: delegate
			width: gridGames.cellWidth
			height: gridGames.cellHeight
			onClicked: pageStack.push (Qt.resolvedUrl("ChannelsPage.qml"),{ bygame: true, game: game.name })

			Image {
				id: logo
				fillMode: Image.PreserveAspectCrop
				source: game.box[posterSize.value]
				anchors {
					fill: parent
					leftMargin: Theme.paddingSmall
					rightMargin: Theme.paddingSmall
					topMargin: Theme.paddingSmall
					bottomMargin: Theme.paddingSmall
				}
				visible: false
			}

			ShaderEffect {
				anchors.fill: logo
				property variant src: logo
				property real h: 2 * name.height/height
				vertexShader: "
					uniform highp mat4 qt_Matrix;
					attribute highp vec4 qt_Vertex;
					attribute highp vec2 qt_MultiTexCoord0;
					varying highp vec2 coord;
					void main() {
						coord = qt_MultiTexCoord0;
						gl_Position = qt_Matrix * qt_Vertex;
					}"
				fragmentShader: "
					varying highp vec2 coord;
					uniform sampler2D src;
					uniform lowp float h;
					uniform lowp float qt_Opacity;
					void main() {
						lowp vec4 tex = texture2D(src, coord);
						if(coord.y <= h)
							tex = vec4((tex.rgb)*(coord.y/(h)), coord.y/(h));
						gl_FragColor = tex * qt_Opacity;
					}"
			}

			Label {
				id: name
				anchors {
					left: parent.left; leftMargin: Theme.paddingLarge
					right: parent.right; rightMargin: Theme.paddingLarge
					topMargin: Theme.paddingMedium
				}
				text: game.name
				truncationMode: TruncationMode.Fade
				color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
				font.pixelSize: Theme.fontSizeSmall
			}
        }

		VerticalScrollDecorator { flickable: gridGames }
    }

	Component.onCompleted: {
		HTTP.getRequest("https://api.twitch.tv/kraken/games/top?limit="+countOnPage, function (data) {
			if (data) {
				var result = JSON.parse(data)
				nextlink = result._links.next
				for (var i in result.top)
					gameList.append(result.top[i])
			}
		})
	}
}



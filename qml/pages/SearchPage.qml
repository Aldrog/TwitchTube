import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0
import "scripts/httphelper.js" as HTTP

Page {
	id: page
	allowedOrientations: Orientation.All

	property int row: isPortrait ? 2 : 3
	//in brackets should be row lengths for portrait and landscape orientations
	property int countOnPage: (2*3)*2

	ConfigurationValue {
		id: previewSize
		key: "/apps/twitch/settings/previewimgsize"
		defaultValue: "medium"
	}

	SilicaGridView {
		id: gridResults
		anchors.fill: parent

		PullDownMenu {
			MenuItem {
				text: qsTr("Settings")
				onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
			}

			MenuItem {
				text: qsTr("Following")
			}

			MenuItem {
				text: qsTr("Channels")
				onClicked: pageStack.replaceAbove(null, Qt.resolvedUrl("ChannelsPage.qml"))
			}

			MenuItem {
				text: qsTr("Games")
				onClicked: pageStack.replaceAbove(null, Qt.resolvedUrl("GamesPage.qml"))
			}
		}

		header: SearchField {
			id: searchQuerry
			width: parent.width
			placeholderText: qsTr("Search channels")
			onTextChanged: {
				resultList.clear()
				var url = "https://api.twitch.tv/kraken/search/streams?q=" + encodeURI(text) + "&limit=" + countOnPage
				console.log(url)
				HTTP.getRequest(url,function(data) {
					if (data) {
						var result = JSON.parse(data)
						//nextlink = result._links.next
						for (var i in result.streams)
							resultList.append(result.streams[i])
					}
				})
			}
		}

		//This prevents search field from loosing focus when grid changes
		currentIndex: -1

		model: ListModel { id: resultList }
		cellWidth: width/row
		cellHeight: cellWidth*5/8

		delegate: BackgroundItem {
			id: delegate
			width: gridResults.cellWidth
			height: gridResults.cellHeight
			onClicked: pageStack.push (Qt.resolvedUrl("StreamPage.qml"), { channel: channel.name })

			Image {
				id: previewImage
				source: preview[previewSize.value]
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
				anchors.fill: previewImage
				property variant src: previewImage
				property real h: name.height/height
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
				text: channel.display_name
				truncationMode: TruncationMode.Fade
				color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
				font.pixelSize: Theme.fontSizeSmall
			}
		}

		VerticalScrollDecorator { flickable: gridResults }
	}
}

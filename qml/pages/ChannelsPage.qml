import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0
import "scripts/httphelper.js" as HTTP


Page {
	id: page
	allowedOrientations: Orientation.All

	property bool bygame: false
	property string game
	property int row: isPortrait ? 2 : 3
	//in brackets should be row lengths for portrait and landscape orientations
	property int countOnPage: (2*3)*3
	property string nextlink

	ConfigurationValue {
		id: previewSize
		key: "/apps/twitch/settings/previewimgsize"
		defaultValue: "large"
	}

	SilicaGridView {
		id: gridChannels
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
				onClicked: pageStack.replaceAbove(null, Qt.resolvedUrl("FollowedPage.qml"))
			}

			MenuItem {
				text: qsTr("Channels")
				onClicked: pageStack.replaceAbove(null, Qt.resolvedUrl("ChannelsPage.qml"))
				visible: bygame
			}

			MenuItem {
				text: qsTr("Games")
				onClicked: pageStack.replaceAbove(null, Qt.resolvedUrl("GamesPage.qml"))
				visible: !bygame
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
							for (var i in result.streams)
								streamList.append(result.streams[i])
						}
					})
				}
			}
		}

		header: PageHeader {
			title: bygame ? game : qsTr("Live Channels")
		}

		model: ListModel { id: streamList }
		cellWidth: width/row
		cellHeight: cellWidth*5/8

		delegate: BackgroundItem {
			id: delegate
			width: gridChannels.cellWidth
			height: gridChannels.cellHeight
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

		VerticalScrollDecorator { flickable: gridChannels }
	}

	Component.onCompleted: {
		var url = "https://api.twitch.tv/kraken/streams?limit=" + countOnPage
		if (bygame)
			url += encodeURI("&game=" + game)
		console.log(url)
		HTTP.getRequest(url,function(data) {
			if (data) {
				var result = JSON.parse(data)
				nextlink = result._links.next
				for (var i in result.streams)
					streamList.append(result.streams[i])
			}
		})
	}
}






import QtQuick 2.4
import Ubuntu.Components 1.3
import "pages"
import "js/httphelper.js" as HTTP

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    id: mainWindow

    property string username

    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "TwitchTube"

    width: units.gu(100)
    height: units.gu(75)

    Component.onCompleted: {
        if(authToken.value) {
            HTTP.getRequest("https://api.twitch.tv/kraken/user?oauth_token=" + authToken.value, function(data) {
                if(data) {
                    var user = JSON.parse(data)
                    username = user.name
                    console.log("Successfully received username")
                }
            })
        }
    }

    PageStack {
        id: pageStack
        Component.onCompleted: push(startingPage)
        GamesPage {
            id: startingPage
            visible: false
        }
    }
}

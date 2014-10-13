import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0

Page {
    id: page
    MediaPlayer {
        id: player
        function httpget(){
            var http = new XMLHttpRequest()
            var url = "https://api.twitch.tv/api/channels/versuta/access_token";
            http.open("GET", url, true);
            http.setRequestHeader("Connection", "close");
            http.onreadystatechange = function() { // Call a function when the state changes.
                if (http.readyState == 4) {
                    if (http.status == 200) {
                        console.log("ok")
                    } else {
                        console.log("error: " + http.status)
                    }
                }
            }
            http.send(params);
            return http.responseXML;
        }

        source: httpget().sig
        autoPlay: true
    }

    VideoOutput {
        id: streamVideo
        source: player
        anchors.fill: parent
    }
}

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0

Page {
	id: page
	allowedOrientations: Orientation.All

	ConfigurationValue {
		id: authToken
		key: "/apps/twitch/settings/oauthtoken"
		defaultValue: ""
	}

	PageHeader {
		id: head
		title: qsTr("Log into your Twitch account")
	}

	SilicaWebView {
		id: twitchLogin
		anchors {
			top: head.bottom
			bottom: parent.bottom
			left: parent.left
			right: parent.right
		}
		onNavigationRequested: {
			console.log(request.url)
			console.log(request.url.toString().split('#')[1])
			if(request.url.toString().split('#')[0] === "http://localhost/") {
				authToken.value = request.url.toString().split('=')[1].split('&')[0]
				console.log(authToken.value)
				navigateBack()
			}
			else
				request.action = SilicaWebView.AcceptRequest;
		}
		url: encodeURI("https://api.twitch.tv/kraken/oauth2/authorize?response_type=token&client_id=n57dx0ypqy48ogn1ac08buvoe13bnsu&redirect_uri=http://localhost&scope=user_read user_follows_edit")
	}
}

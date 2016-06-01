/*
 * Copyright © 2015-2016 Andrew Penkrat
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

#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#ifdef OS_SAILFISH
#include <sailfishapp.h>
#endif

#include <QtQml>
#include <QGuiApplication>
#include <QQuickView>

#include "ircchat.h"
#include "message.h"
#include "qmlsettings.h"
#include "tools.h"

//All app settings are declared here so it's easy to change default value or setting's key
void registerSettings(QQuickView *view) {
    QMLSettings *authToken = new QMLSettings();
    authToken->setKey("User/TwitchOAuth2Token");
    authToken->setDefaultValue("");
    view->rootContext()->setContextProperty("authToken", authToken);

    QMLSettings *gameImageSize = new QMLSettings();
    gameImageSize->setKey("Interface/GameImageSize");
    gameImageSize->setDefaultValue("large");
    view->rootContext()->setContextProperty("gameImageSize", gameImageSize);

    QMLSettings *channelImageSize = new QMLSettings();
    channelImageSize->setKey("Interface/ChannelImageSize");
    channelImageSize->setDefaultValue("large");
    view->rootContext()->setContextProperty("channelImageSize", channelImageSize);

    QMLSettings *showBroadcastTitles = new QMLSettings();
    showBroadcastTitles->setKey("Interface/ShowBroadcastTitles");
    showBroadcastTitles->setDefaultValue(true);
    view->rootContext()->setContextProperty("showBroadcastTitles", showBroadcastTitles);

    QMLSettings *chatFlowBtT = new QMLSettings();
    chatFlowBtT->setKey("Interface/ChatFlowBottomToTop");
    chatFlowBtT->setDefaultValue(false);
    view->rootContext()->setContextProperty("chatFlowBtT", chatFlowBtT);

    QMLSettings *streamQuality = new QMLSettings();
    streamQuality->setKey("Video/StreamQuality");
    streamQuality->setDefaultValue("medium");
    view->rootContext()->setContextProperty("streamQuality", streamQuality);
}

int main(int argc, char *argv[])
{
    // SailfishApp::main() will display "qml/template.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //
    // To display the view, call "show()" (will show fullscreen on device).

#ifdef OS_SAILFISH
    QGuiApplication *app(SailfishApp::application(argc, argv));
    QCoreApplication::setOrganizationName("harbour-twitchtube");
    QCoreApplication::setApplicationName("harbour-twitchtube");
    qmlRegisterType<IrcChat>("harbour.twitchtube.ircchat", 1, 0, "IrcChat");
    qmlRegisterType<MessageListModel>("harbour.twitchtube.ircchat", 1, 0, "MessageListModel");
    qmlRegisterType<QMLSettings>("harbour.twitchtube.settings", 1, 0, "Setting");

    QQuickView *view(SailfishApp::createView());
#else
    QGuiApplication *app = new QGuiApplication(argc, argv);
    QCoreApplication::setOrganizationName("harbour-twitchtube");
    QCoreApplication::setApplicationName("harbour-twitchtube");
    qmlRegisterType<IrcChat>("aldrog.twitchtube.ircchat", 1, 0, "IrcChat");
    qmlRegisterType<MessageListModel>("aldrog.twitchtube.ircchat", 1, 0, "MessageListModel");
    qmlRegisterType<QMLSettings>("aldrog.twitchtube.settings", 1, 0, "Setting");

    QQuickView *view = new QQuickView();
#endif

    registerSettings(view);
    Tools *tools = new Tools();
    view->rootContext()->setContextProperty("cpptools", tools);

    view->setSource(QUrl("qrc:///Main.qml"));
    view->setResizeMode(QQuickView::SizeRootObjectToView);
    view->show();
    return app->exec();
}

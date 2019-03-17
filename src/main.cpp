/*
 * Copyright © 2015-2017, 2019 Andrew Penkrat
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

#include <sailfishapp.h>

#include <QtQml>
#include <QGuiApplication>
#include <QQuickView>

#include <Models/topgamesmodel.h>
#include <Models/streamsmodel.h>
#include <Models/followedchannelsmodel.h>
#include <Models/gamessearchmodel.h>
#include <Models/streamssearchmodel.h>
#include <Models/channelssearchmodel.h>
#include <Models/playlistmodel.h>
#include <Models/userinfo.h>
#include <Api/client.h>
#include <Api/qsettingscredentialsstorage.h>

#include "ircchat.h"
#include "message.h"
#include "qmlsettings.h"
#include "iconprovider.h"

// All app settings are declared here so it's easy to change default value or setting's key
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
    streamQuality->setDefaultValue(1);
    view->rootContext()->setContextProperty("streamQuality", streamQuality);
}

int main(int argc, char *argv[])
{
    QGuiApplication *app(SailfishApp::application(argc, argv));
    QCoreApplication::setOrganizationName("harbour-twitchtube");
    QCoreApplication::setApplicationName("harbour-twitchtube");
    qmlRegisterType<IrcChat>("harbour.twitchtube.ircchat", 1, 0, "IrcChat");
    qmlRegisterType<MessageListModel>("harbour.twitchtube.ircchat", 1, 0, "MessageListModel");
    qmlRegisterType<QMLSettings>("harbour.twitchtube.settings", 1, 0, "Setting");

    qmlRegisterType<QTwitch::Models::TopGamesModel>        ("QTwitch.Models", 0, 1, "TopGamesModel");
    qmlRegisterType<QTwitch::Models::StreamsModel>         ("QTwitch.Models", 0, 1, "StreamsModel");
    qmlRegisterType<QTwitch::Models::FollowedChannelsModel>("QTwitch.Models", 0, 1, "FollowedChannelsModel");
    qmlRegisterType<QTwitch::Models::GamesSearchModel>     ("QTwitch.Models", 0, 1, "GamesSearchModel");
    qmlRegisterType<QTwitch::Models::StreamsSearchModel>   ("QTwitch.Models", 0, 1, "StreamsSearchModel");
    qmlRegisterType<QTwitch::Models::ChannelsSearchModel>  ("QTwitch.Models", 0, 1, "ChannelsSearchModel");
    qmlRegisterType<QTwitch::Models::PlaylistModel>        ("QTwitch.Models", 0, 1, "PlaylistModel");
    qmlRegisterType<QTwitch::Models::UserInfo>             ("QTwitch.Models", 0, 1, "UserInfo");

    qmlRegisterSingletonType<QTwitch::Api::Client>("QTwitch.Api", 0, 1, "Client", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return QTwitch::Api::Client::get().get();
    });
    auto storage = std::make_unique<QTwitch::Api::QSettingsCredentialsStorage>(QSettings::UserScope, QCoreApplication::organizationName(), QCoreApplication::applicationName());
    QTwitch::Api::Client::get()->authorization()->setCredentialsStorage(std::move(storage));

    QQuickView *view(SailfishApp::createView());
    view->engine()->addImageProvider(QStringLiteral("app-icons"), new IconProvider);

    registerSettings(view);

    view->setSource(SailfishApp::pathToMainQml());
    view->show();
    return app->exec();
}

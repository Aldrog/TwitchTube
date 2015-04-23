/*
 * Copyright © 2015 Andrew Penkrat
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
#include <gst/gst.h>

#include "ircchat.h"
#include "videoplayer.h"
#include "tools.h"

int main(int argc, char *argv[])
{
    gst_init(&argc, &argv);

    // SailfishApp::main() will display "qml/template.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //
    // To display the view, call "show()" (will show fullscreen on device).

	QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
	qmlRegisterType<IrcChat>("harbour.twitchtube.ircchat", 1, 0, "IrcChat");
	qmlRegisterType<VideoPlayer>("harbour.twitchtube.gstreamer", 1, 0, "VideoPlayer");
	QScopedPointer<QQuickView> view(SailfishApp::createView());
	Tools* t = new Tools();
	view->rootContext()->setContextProperty("tools", t);
	view->setSource(SailfishApp::pathTo("qml/harbour-twitchtube.qml"));
	view->show();
    return app->exec();
}

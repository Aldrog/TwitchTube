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

#include "tools.h"
#include <QStringList>
#include <QDir>
#include <QStandardPaths>
#include <QDebug>

#ifdef OS_SAILFISH
#include <QDBusReply>
#endif

Tools::Tools(QObject *parent) :
    QObject(parent)
#ifdef OS_SAILFISH
  , mceReqInterface("com.nokia.mce",
                    "/com/nokia/mce/request",
                    "com.nokia.mce.request",
                    QDBusConnection::connectToBus(QDBusConnection::SystemBus, "system"))
#endif
{
#ifdef OS_SAILFISH
    pauseRefresher = new QTimer();
    connect(pauseRefresher, SIGNAL(timeout()), this, SLOT(refreshPause()));
#endif
}
Tools::~Tools() { }

/* Return codes:
 * 0 - success
 * 1 - cache doesn't exist
 * -1 - cannot delete cache
 * -2 - failed to find cache directory
 */
int Tools::clearCookies() {
    QStringList dataPaths = QStandardPaths::standardLocations(QStandardPaths::DataLocation);
    if(dataPaths.size()) {
        qDebug() << QDir(dataPaths[0]).entryList();
#ifdef OS_SAILFISH
        QDir webData(QDir(dataPaths.at(0)).filePath(".QtWebKit"));
        if(webData.exists()) {
            if(webData.removeRecursively())
                return 0;
            else
                return -1;
        }
        else
            return 1;
#elif OS_UBUNTU
        QDir webData(QDir(dataPaths.at(0)));
        if(webData.exists()) {
            if(webData.removeRecursively())
                return 0;
            else
                return -1;
        }
        else
            return 1;
#endif
    }
    return -2;
}

#ifdef OS_SAILFISH
// true - screen blanks (default)
// false - no blanking
void Tools::setBlankingMode(bool state)
{
    if (state) {
        qDebug() << "Screen blanking paused";
        mceReqInterface.call(QLatin1String("req_display_cancel_blanking_pause"));
        pauseRefresher->stop();
    } else {
        qDebug() << "Screen blanking enabled";
        mceReqInterface.call(QLatin1String("req_display_blanking_pause"));
        pauseRefresher->start(PAUSE_PERIOD);
    }
}

void Tools::refreshPause() {
    QDBusReply<QString> pauseValue = mceReqInterface.call(QLatin1String("get_display_blanking_pause"));
    if(pauseValue.isValid())
        qDebug() << "Blanking pause is" << pauseValue.value() << ", refreshing pause period";

    mceReqInterface.call(QLatin1String("req_display_blanking_pause"));
}
#endif

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

#ifndef GSTPLAYER_H
#define GSTPLAYER_H

#include <QObject>
#include <gst/gst.h>

class GstPlayer : public QObject
{
    Q_OBJECT
public:
	Q_PROPERTY(QString source WRITE setSource READ getSource NOTIFY sourceChanged)

    explicit GstPlayer(QObject *parent = 0);
    ~GstPlayer();

	void setSource(QString source);
	QString getSource();
	QString uri;
signals:
	void sourceChanged();

public slots:
	void play();
	void stop();

private:
	GMainLoop *loop;
	GstElement *playbin;

	static gboolean
	bus_call (GstBus     *bus,
			  GstMessage *msg,
			  gpointer    data);
};

#endif // GSTPLAYER_H

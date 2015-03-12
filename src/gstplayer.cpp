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

#include "gstplayer.h"

gboolean
GstPlayer::bus_call (GstBus     *bus,
		  GstMessage *msg,
		  gpointer    data) {
	GMainLoop *loop = (GMainLoop *) data;

	switch (GST_MESSAGE_TYPE (msg)) {

	case GST_MESSAGE_EOS:
		qDebug("End of stream\n");
		g_main_loop_quit (loop);
		break;

	case GST_MESSAGE_ERROR: {
		gchar  *debug;
		GError *error;

		gst_message_parse_error (msg, &error, &debug);
		g_free (debug);

		qDebug("Error: %s", error->message);
		g_error_free (error);

		g_main_loop_quit (loop);
		break;
	}
	default:
		break;
	}

	return TRUE;
}

GstPlayer::GstPlayer(QObject *parent) :
					 QObject(parent) {
	GstBus *bus;

	loop = g_main_loop_new (NULL, FALSE);
	playbin = gst_element_factory_make ("playbin", "play");
	bus = gst_pipeline_get_bus (GST_PIPELINE (playbin));
	gst_bus_add_watch (bus, bus_call, loop);
	gst_object_unref (bus);

}

GstPlayer::~GstPlayer() {
	/* also clean up */
	gst_element_set_state (playbin, GST_STATE_NULL);
	gst_object_unref (GST_OBJECT (playbin));
}

void GstPlayer::play() {
	gst_element_set_state (playbin, GST_STATE_PLAYING);
	/* now run */
	g_main_loop_run (loop);
}

void GstPlayer::stop() {
}

void GstPlayer::setSource(QString source) {
	if(uri != source) {
		this->uri = source;
		g_object_set (G_OBJECT (playbin), "uri", uri.toStdString().c_str(), NULL);
		sourceChanged();
	}
}

QString GstPlayer::getSource() {
	return uri;
}

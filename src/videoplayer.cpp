/*
 * Copyright (C) 2012-2014 Mohammed Sameer <msameer@foolab.org>
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

#include "videoplayer.h"
#include <QQmlInfo>
#include <QTimer>
#include "qtviewfinderrenderer.h"
#include <QPainter>
#include <QMatrix4x4>
#include <cmath>

VideoPlayer::VideoPlayer(QQuickItem *parent) :
	QQuickPaintedItem(parent),
	m_renderer(0),
	m_bin(0),
	m_state(VideoPlayer::StateStopped),
	m_timer(new QTimer(this)),
	m_pos(0),
	m_volume(0),
	m_watch(0) {

	m_timer->setSingleShot(false);
	m_timer->setInterval(500);
	QObject::connect(m_timer, SIGNAL(timeout()), this, SIGNAL(positionChanged()));

	setRenderTarget(QQuickPaintedItem::FramebufferObject);
	setSmooth(false);
	setAntialiasing(false);
}

VideoPlayer::~VideoPlayer() {
	if (m_volume > 0) {
		g_signal_handler_disconnect(m_bin, m_volume);
		m_volume = 0;
	}

	if (m_watch) {
		g_source_remove(m_watch);
		m_watch = 0;
	}

	stop();

	if (m_bin) {
		gst_object_unref(m_bin);
		m_bin = 0;
	}
}

void VideoPlayer::componentComplete() {
	QQuickPaintedItem::componentComplete();

	m_renderer = new QtViewfinderRenderer(this);
	if (!m_renderer) {
		qmlInfo(this) << "Failed to create viewfinder renderer";
		return;
	}

	m_renderer->resize(QSizeF(width(), height()));
	QObject::connect(m_renderer, SIGNAL(updateRequested()), this, SLOT(updateRequested()));

	if (m_bin) {
		g_object_set(m_bin, "video-sink", m_renderer->sinkElement(), NULL);
	}
}

void VideoPlayer::classBegin() {
	QQuickPaintedItem::classBegin();

	m_bin = gst_element_factory_make ("playbin", "VideoPlayerBin");
	if (!m_bin) {
		qmlInfo(this) << "Failed to create playbin";
		return;
	}

	m_volume =
			g_signal_connect (G_OBJECT (m_bin), "notify::volume", G_CALLBACK (on_volume_changed), this);
	g_object_set (m_bin, "flags", 99, NULL);

	GstElement *elem = gst_element_factory_make("pulsesink", "VideoPlayerPulseSink");
	if (!elem) {
		qmlInfo(this) << "Failed to create pulsesink";
	}
	else {
		g_object_set (m_bin, "audio-sink", elem, NULL);
	}

	GstBus *bus = gst_element_get_bus(m_bin);
	m_watch = gst_bus_add_watch(bus, bus_call, this);
	gst_object_unref(bus);
}

QUrl VideoPlayer::source() const {
	return m_url;
}

void VideoPlayer::setSource(const QUrl& source) {
	if (m_url != source) {
		m_url = source;
		emit sourceChanged();
	}
}

qint64 VideoPlayer::duration() const {
	if (!m_bin) {
		return 0;
	}

	qint64 dur = 0;

#if GST_CHECK_VERSION(1,0,0)
	if (!gst_element_query_duration(m_bin, GST_FORMAT_TIME, &dur)) {
		return 0;
	}
#else
	GstFormat format = GST_FORMAT_TIME;
	if (!gst_element_query_duration(m_bin, &format, &dur)) {
		return 0;
	}

	if (format != GST_FORMAT_TIME) {
		qmlInfo(this) << "Pipeline format is not time";
		return 0;
	}
#endif

	dur /= 1000000;

	return dur;
}

qint64 VideoPlayer::position() {
	if (!m_bin) {
		return 0;
	}

	qint64 pos = 0;

#if GST_CHECK_VERSION(1,0,0)
	if (!gst_element_query_position(m_bin, GST_FORMAT_TIME, &pos)) {
		return m_pos;
	}
#else
	GstFormat format = GST_FORMAT_TIME;
	if (!gst_element_query_position(m_bin, &format, &pos)) {
		return m_pos;
	}

	if (format != GST_FORMAT_TIME) {
		qmlInfo(this) << "Pipeline format is not time";
		return m_pos;
	}
#endif

	pos /= 1000000;

	m_pos = pos;

	return pos;
}

void VideoPlayer::setPosition(qint64 position) {
	seek(position);
}

bool VideoPlayer::pause() {
	return setState(VideoPlayer::StatePaused);
}

bool VideoPlayer::play() {
	return setState(VideoPlayer::StatePlaying);
}

bool VideoPlayer::seek(qint64 offset) {
	if (!m_bin) {
		qmlInfo(this) << "no playbin";
		return false;
	}

	qint64 pos = offset;

	offset *= 1000000;

	GstSeekFlags flags = (GstSeekFlags)(GST_SEEK_FLAG_FLUSH | GST_SEEK_FLAG_ACCURATE);
	gboolean ret = gst_element_seek_simple (m_bin, GST_FORMAT_TIME,
											flags, offset);

	if (ret) {
		m_pos = pos;

		return TRUE;
	}

	return FALSE;
}

bool VideoPlayer::stop() {
	return setState(VideoPlayer::StateStopped);
}

void VideoPlayer::geometryChanged(const QRectF& newGeometry, const QRectF& oldGeometry) {
	QQuickPaintedItem::geometryChanged(newGeometry, oldGeometry);

	if (m_renderer) {
		m_renderer->resize(newGeometry.size());
	}
}

void VideoPlayer::paint(QPainter *painter) {
	painter->fillRect(contentsBoundingRect(), Qt::black);

	if (!m_renderer) {
		return;
	}

	bool needsNativePainting = m_renderer->needsNativePainting();

	if (needsNativePainting) {
		painter->beginNativePainting();
	}

	m_renderer->paint(QMatrix4x4(painter->combinedTransform()), painter->viewport());

	if (needsNativePainting) {
		painter->endNativePainting();
	}
}

VideoPlayer::State VideoPlayer::state() const {
	return m_state;
}

bool VideoPlayer::setState(const VideoPlayer::State& state) {
	if (state == m_state) {
		return true;
	}

	if (!m_bin) {
		qmlInfo(this) << "no playbin";
		return false;
	}

	if (state == VideoPlayer::StatePaused) {
		m_timer->stop();

		// Set uri if needed:
		if (m_state == VideoPlayer::StateStopped) {
			const char *uri = m_url.toString().toUtf8().constData();
			g_object_set(m_bin, "uri", uri, NULL);
		}

		if (gst_element_set_state(m_bin, GST_STATE_PAUSED) == GST_STATE_CHANGE_FAILURE) {
			qmlInfo(this) << "error setting pipeline to PAUSED";
			return false;
		}

		GstState st;
		if (gst_element_get_state(m_bin, &st, NULL, GST_CLOCK_TIME_NONE)
				== GST_STATE_CHANGE_FAILURE) {
			qmlInfo(this) << "setting pipeline to PAUSED failed";
			return false;
		}

		if (st != GST_STATE_PAUSED) {
			qmlInfo(this) << "pipeline failed to transition to to PAUSED state";
			return false;
		}

		m_state = state;
		emit stateChanged();

		return true;
	}
	else if (state == VideoPlayer::StatePlaying) {
		// Set uri if needed:
		if (m_state == VideoPlayer::StateStopped) {
			const char *uri = m_url.toString().toUtf8().constData();
			g_object_set(m_bin, "uri", uri, NULL);
		}

		if (gst_element_set_state(m_bin, GST_STATE_PLAYING) == GST_STATE_CHANGE_FAILURE) {
			qmlInfo(this) << "error setting pipeline to PLAYING";
			return false;
		}

		GstState st;
		if (gst_element_get_state(m_bin, &st, NULL, GST_CLOCK_TIME_NONE)
				== GST_STATE_CHANGE_FAILURE) {
			qmlInfo(this) << "setting pipeline to PLAYING failed";
			return false;
		}

		if (st != GST_STATE_PLAYING) {
			qmlInfo(this) << "pipeline failed to transition to to PLAYING state";
			return false;
		}

		m_state = state;
		emit stateChanged();

		emit durationChanged();
		emit positionChanged();

		m_timer->start();
		return true;
	}
	else {
		m_timer->stop();
		m_pos = 0;

		if (gst_element_set_state(m_bin, GST_STATE_NULL) == GST_STATE_CHANGE_FAILURE) {
			qmlInfo(this) << "error setting pipeline to NULL";
			return false;
		}

		GstState st;
		if (gst_element_get_state(m_bin, &st, NULL, GST_CLOCK_TIME_NONE)
				== GST_STATE_CHANGE_FAILURE) {
			qmlInfo(this) << "setting pipeline to NULL failed";
			return false;
		}

		if (st != GST_STATE_NULL) {
			qmlInfo(this) << "pipeline failed to transition to to NULL state";
			return false;
		}

		m_state = state;
		emit stateChanged();

		emit durationChanged();
		emit positionChanged();

		return true;
	}
}

gboolean VideoPlayer::bus_call(GstBus *bus, GstMessage *msg, gpointer data) {
	Q_UNUSED(bus);

	VideoPlayer *that = (VideoPlayer *) data;

	gchar *debug = NULL;
	GError *err = NULL;

	switch (GST_MESSAGE_TYPE(msg)) {
	case GST_MESSAGE_EOS:
		that->stop();
		return FALSE;

	case GST_MESSAGE_ERROR:
		gst_message_parse_error (msg, &err, &debug);

		emit that->error(err->message, err->code, debug);
		that->stop();

		if (err) {
			g_error_free (err);
		}

		if (debug) {
			g_free (debug);
		}

		return FALSE;

	default:
		return TRUE;
	}
}

void VideoPlayer::updateRequested() {
	update();
}

quint32 VideoPlayer::volume() {
	double vol = 1.0;
	g_object_get (m_bin, "volume", &vol, NULL);

	qint32 res = (int)round(vol * 100.0);

	return res;
}

void VideoPlayer::setVolume(quint32 volume) {
	if (VideoPlayer::volume() != volume) {
		double vol = volume / 100.0;
		g_object_set (m_bin, "volume", vol, NULL);
		emit volumeChanged();
	}
}

void VideoPlayer::on_volume_changed(GObject *object, GParamSpec *pspec, gpointer user_data) {
	Q_UNUSED(object);
	Q_UNUSED(pspec);

	VideoPlayer *player = (VideoPlayer *) user_data;

	QMetaObject::invokeMethod(player, "volumeChanged", Qt::QueuedConnection);
}

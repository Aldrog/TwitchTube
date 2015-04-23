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

#ifndef QT_VIEWFINDER_RENDERER_H
#define QT_VIEWFINDER_RENDERER_H

#include <QObject>
#include <QRectF>
#include <QMutex>
#include <QMatrix4x4>
#include <gst/gst.h>
#include <gst/video/video.h>
#include <QOpenGLShaderProgram>
#include <gst/meta/nemometa.h>

class QMetaObject;
class QMatrix4x4;
class QSizeF;

typedef void *EGLDisplay;

class QtViewfinderRenderer : public QObject {
	Q_OBJECT

public:
	QtViewfinderRenderer(QObject *parent = 0);

	~QtViewfinderRenderer();

	virtual void paint(const QMatrix4x4& matrix, const QRectF& viewport);
	virtual void resize(const QSizeF& size);
	virtual void reset();
	virtual void start();
	virtual GstElement *sinkElement();

	QRectF renderArea();
	QSizeF videoResolution();

	bool needsNativePainting();

	virtual void setViewfinderRotationAngle(int angle);
	virtual void setViewfinderFlipped(bool flipped);

	void calculateCoordinates(const QRect& crop, float *coords);

signals:
  void updateRequested();
  void renderAreaChanged();
  void videoResolutionChanged();

private slots:
	void setVideoSize(const QSizeF& size);

protected:
	int m_angle;
	bool m_flipped;

private:
	static void frame_ready(GstElement *sink, int frame, QtViewfinderRenderer *r);
	static void sink_notify(QtViewfinderRenderer *q, GObject *object, gboolean is_last_ref);
	static void sink_caps_changed(GObject *obj, GParamSpec *pspec, QtViewfinderRenderer *q);

	void calculateProjectionMatrix(const QRectF& rect);
	void createProgram();
	void paintFrame(const QMatrix4x4& matrix, int frame);
	void calculateVertexCoords();

	void cleanup();
	void updateCropInfo(const GstVideoCropMeta *crop, GLfloat *texCoords, int index);

	GstElement *m_sink;
	QMutex m_frameMutex;
	int m_frame;
	unsigned long m_id;
	unsigned long m_notify;
	bool m_needsInit;
	QOpenGLShaderProgram *m_program;
	QMatrix4x4 m_projectionMatrix;
	GLfloat m_vertexCoords[8];
	QSizeF m_size;
	QSizeF m_videoSize;
	QRectF m_renderArea;
	EGLDisplay m_dpy;
	bool m_displaySet;
	bool m_started;
};

#endif /* QT_VIEWFINDER_RENDERER_H */

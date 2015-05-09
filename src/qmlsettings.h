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

#ifndef QMLSETTINGS_H
#define QMLSETTINGS_H

#include <QSettings>

class QMLSettings : public QSettings
{
	Q_OBJECT
public:
	explicit QMLSettings(QObject *parent = 0);
	Q_INVOKABLE inline void setValue(const QString &key, const QVariant &value) { QSettings::setValue(key, value); emit changeChanged(); }
	Q_INVOKABLE inline QVariant value(const QString &key, const QVariant &defaultValue = QVariant(), bool nothing = true) const { return QSettings::value(key, defaultValue); }

	// Fake property
	Q_PROPERTY(bool change READ change NOTIFY changeChanged)
	bool change();
	//TODO: Rework this class in order to get rid of fake property hack

signals:
	void changeChanged();

public slots:

};

#endif // QMLSETTINGS_H

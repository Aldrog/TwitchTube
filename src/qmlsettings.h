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
    Q_PROPERTY(QString key READ key WRITE setKey NOTIFY keyChanged)
    Q_PROPERTY(QVariant defaultValue READ defaultValue WRITE setDefaultValue NOTIFY defaultValueChanged)
    Q_PROPERTY(QVariant value READ value WRITE setValue NOTIFY valueChanged)

    QMLSettings(QObject *parent = 0);

    inline QString key() { return key_p; }
    void setKey(QString key);
    inline QVariant defaultValue() { return default_p; }
    void setDefaultValue(QVariant defaultValue);
    QVariant value();
    void setValue(QVariant value);

signals:
    void keyChanged();
    void defaultValueChanged();
    void valueChanged();

private:
    QString key_p;
    QVariant default_p;
};

#endif // QMLSETTINGS_H

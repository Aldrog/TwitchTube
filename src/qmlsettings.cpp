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

#include "qmlsettings.h"
#include <QCoreApplication>
#include <QDebug>

QMLSettings::QMLSettings(QObject *parent) : QSettings(QSettings::UserScope, QCoreApplication::organizationName(), QCoreApplication::applicationName(), parent){}

void QMLSettings::setKey(QString key) {
	if(key != _key) {
		_key = key;
		emit keyChanged();
	}
}

void QMLSettings::setDefaultValue(QVariant defaultValue) {
	if(defaultValue != _default) {
		_default = defaultValue;
		emit defaultValueChanged();
	}
}

QVariant QMLSettings::value() {
	QVariant val = QSettings::value(_key, _default);
	qDebug() << _key << val << _default.type();
	if(val.convert(_default.type())) {
		qDebug() << "passed" << val;
		return val;
	}
	else return QSettings::value(_key, _default);
}

void QMLSettings::setValue(QVariant value) {
	qDebug() << value;
	if(value != this->value()) {
		QSettings::setValue(_key, value);
		emit valueChanged();
	}
}

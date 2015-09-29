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

#include "message.h"

Message::Message(QObject *parent) :
	QObject(parent)
{
}

Message::Message(QStringList specs, QColor uColor, QString d_name, QString uname, QString text) {
	userSpecificators = specs;
	userColor = uColor;
	displayName = d_name;
	username = uname;
	messageText = text;
	notice = false;
	emit isNoticeChanged();
}

Message::Message(QString RTMessage, QStringList specs, QColor uColor, QString d_name, QString uname, QString text) {
	userSpecificators = specs;
	userColor = uColor;
	displayName = d_name;
	username = uname;
	messageText = text;
	notice = false;
	emit isNoticeChanged();
	RT = RTMessage;
	emit richTextChanged();
}

Message::Message(QString RTNotice, QString text) {
	userSpecificators = QStringList();
	userColor = QColor();
	displayName = "";
	username = "";
	messageText = text;
	RT = RTNotice;
	emit richTextChanged();
	notice = true;
	emit isNoticeChanged();
}

void Message::setRichText(QString RTMessage) {
	if(RTMessage != RT) {
		RT = RTMessage;
		emit richTextChanged();
	}
}

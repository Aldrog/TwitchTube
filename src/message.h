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

#ifndef MESSAGE_H
#define MESSAGE_H

#include <QStringList>
#include <QColor>

class Message
{
public:
	Message();
	// Message constructor
	Message(QStringList specs, QColor uColor, QString d_name, QString uname, QString text, QString RTMessage = "");
	// Notice constructor
	Message(QString RTNotice, QString text);

	QStringList userSpecificators;
	QColor userColor;
	QString displayName;
	QString username;
	QString messageText;
	bool notice;
	QString richTextMessage;
};

#endif // MESSAGE_H

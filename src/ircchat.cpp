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

#include "ircchat.h"

IrcChat::IrcChat(QObject *parent) :
	QObject(parent) {
	sock = new QTcpSocket(this);
	if(sock) {
		errorOccured("Error opening socket");
	}
	connect(sock, SIGNAL(readyRead()), this, SLOT(receive()));
	connect(sock, SIGNAL(error(QAbstractSocket::SocketError)), this, SLOT(processError(QAbstractSocket::SocketError)));
	connect(sock, SIGNAL(connected()), this, SLOT(onSockStateChanged()));
	connect(sock, SIGNAL(disconnected()), this, SLOT(onSockStateChanged()));
}

IrcChat::~IrcChat() { sock->close(); }

void IrcChat::join(const QString channel) {
	sock->connectToHost(HOST, PORT);
	emit connectedChanged();
	// Tell server that we support twitch-specific commands
	sock->write("CAP REQ :twitch.tv/commands\n");
	sock->write("CAP REQ :twitch.tv/tags\n");
	// Login
	sock->write(("PASS " + ircpass + "\n").toStdString().c_str());
	sock->write(("NICK " + nick + "\n").toStdString().c_str());
	// Join channel's chat room
	sock->write(("JOIN #" + channel + "\n").toStdString().c_str());
	// Save channel name for later use
	room = channel;
}

void IrcChat::setBadge(QString name, QString imageURL) {
	badges.insert(name, imageURL);
}

void IrcChat::setUserEmote(int id, QString pattern) {
	userEmotes.insert(id, QRegExp("\\b" + pattern + "\\b"));
}

void IrcChat::disconnect() {
	sock->close();
}

void IrcChat::reopenSocket() {
	if(sock->isOpen())
		sock->close();
	sock->open(QIODevice::ReadWrite);
	if(!sock->isOpen()) {
		errorOccured("Error opening socket");
	}
}

void IrcChat::sendMessage(const QString &msg) {
	sock->write(("PRIVMSG #" + room + " :" + msg + '\n').toStdString().c_str());
	addMessage("", QColor("Blue"), nick, nick, parseUserEmotes(msg));
}

void IrcChat::receive() {
	QString msg;
	while (sock->canReadLine()) {
		msg = sock->readLine();
		msg = msg.remove('\n').remove('\r');
		parseCommand(msg);
	}
}

void IrcChat::parseCommand(QString cmd) {
	qDebug() << cmd;
	if(cmd.startsWith("PING ")) {
		sock->write(("PONG " + cmd.remove("PING ")).toStdString().c_str());
		return;
	}
	if(cmd.contains("PRIVMSG")) {
		// Structure of message: '@color=#HEX;display-name=NicK;emotes=id:start-end,start-end/id:start-end;subscriber=0or1;turbo=0or1;user-type=type :nick!nick@nick.tmi.twitch.tv PRIVMSG #channel :message'
		QString params = cmd.left(cmd.indexOf("PRIVMSG"));
		QString nickname = params.left(params.lastIndexOf('!')).remove(0, params.lastIndexOf(':') + 1);
		qDebug() << nickname;
		params = params.remove(params.lastIndexOf(':') - 1, params.length());
		// Parsing params
		QString colorCode = getParamValue(params, "color");
		QColor nickColor = colorCode == "" ? getDefaultColor(nickname) : QColor(colorCode);
		QString displayName = getParamValue(params, "display-name");
		QString badgeString = "";
		if(nickname == room)
			badgeString += "<img src=" + badges["broadcaster"] + "/> ";
		QString utype = getParamValue(params, "user-type");
		qDebug() << utype;
		if(utype != "")
			badgeString += "<img src=" + badges[utype] + "/> ";
		if(getParamValue(params, "subscriber") == "1")
			badgeString += "<img src=" + badges["subscriber"] + "/> ";
		qDebug() << badgeString;
		if(getParamValue(params, "turbo") == "1")
			badgeString += "<img src=" + badges["turbo"] + "/> ";

		QStringList emoteList = getParamValue(params, "emotes").split('/', QString::SkipEmptyParts);
		QString message = cmd.remove(0, cmd.indexOf(':', cmd.indexOf("PRIVMSG")) + 1);
		qDebug() << message;
		// Parsing emotes
		QStringList splittedMessage = QStringList(message);
		QVector<int> smLengths = QVector<int>(1, message.length());
		foreach (QString emote, emoteList) {
			//qDebug() << emote;
			int id = emote.left(emote.indexOf(':')).toInt();
			QString richTextEmote = QString("<img src=\'http://static-cdn.jtvnw.net/emoticons/v1/%1/%2.0\'/>").arg(id).arg(_emoteSize);
			//qDebug() << richTextEmote;
			QStringList coordList = emote.remove(0, emote.indexOf(':') + 1).split(',', QString::SkipEmptyParts);
			//qDebug() << coordList;
			foreach (QString position, coordList) {
				//QString position = coordList[j];
				int start = position.left(position.indexOf('-')).toInt();
				int end = position.remove(0, position.indexOf('-') + 1).toInt();
				for(int i = 0; i < splittedMessage.count(); i++) {
					if(start >= smLengths[i]) {
						start -= smLengths[i];
						end -= smLengths[i];
					}
					else {
						QString pieceBeforeEmote = splittedMessage[i].left(start);
						QString pieceAfterEmote = splittedMessage[i].remove(0, end + 1);
						splittedMessage.removeAt(i);
						splittedMessage.insert(i, pieceBeforeEmote);
						splittedMessage.insert(i + 1, richTextEmote);
						splittedMessage.insert(i + 2, pieceAfterEmote);
						smLengths.removeAt(i);
						smLengths.insert(i, pieceBeforeEmote.length());
						smLengths.insert(i + 1, end - start + 1);
						smLengths.insert(i + 2, pieceAfterEmote.length());
						break;
					}
				}
			}
		}
		message = splittedMessage.join("");
		qDebug() << message;
		addMessage(badgeString, nickColor, nickname, displayName, message);
		return;
	}
	if(cmd.contains("GLOBALUSERSTATE")) {
		// We are not interested in this one
		return;
	}
	if(cmd.contains("USERSTATE")) {
		QString params = cmd.left(cmd.lastIndexOf(':') - 1);
		QStringList emoteSets = getParamValue(params, "emote-sets").split(',');
		//TODO
		qDebug() << params;
		return;
	}
	//TODO: NOTICE support
}

QString IrcChat::getParamValue(QString params, QString param) {
	QString paramValue = params.remove(0, params.indexOf(param + "="));
	paramValue = paramValue.left(paramValue.indexOf(';')).remove(0, paramValue.indexOf('=') + 1);
	return paramValue;
}

// Looks like Twitch started to give a random color for every user session. There's no way to get this color, so we continue evaluating color from username.
QColor IrcChat::getDefaultColor(QString name) {
	int n = name[0].unicode() + name[name.length() - 1].unicode();
	return DEFAULTCOLORS[n % (sizeof(DEFAULTCOLORS) / sizeof(*DEFAULTCOLORS))];
}

QString IrcChat::parseUserEmotes(QString msg) {
	QString res = msg;
	foreach (int id, userEmotes.keys()) {
		res = msg.replace(userEmotes[id], QString("<img src=\'http://static-cdn.jtvnw.net/emoticons/v1/%1/%2.0\'/>").arg(id).arg(_emoteSize));
	}
	return res;
}

void IrcChat::setChatList(QStringList newChatList) {
	if(newChatList != chat) {
		chat = newChatList;
		emit chatListChanged();
	}
}

void IrcChat::addMessage(QString badges, QColor nickColor, QString nickname, QString displayName, QString message) {
	chatBadges.insert(0, badges);
	chatNicknames.insert(0, nickname);
	chatMessages.insert(0, message);
	chat.insert(0, badges + "<font color=" + nickColor.name() + ">" + (displayName != "" ? displayName : nickname) + "</font>" + ": " + message);
	emit chatListChanged();
}

void IrcChat::addNotice(QString text) {
	chat.insert(0, text);
	emit chatListChanged();
}

void IrcChat::processError(QAbstractSocket::SocketError socketError) {
	QString err;
	switch (socketError) {
	case QAbstractSocket::RemoteHostClosedError:
		err = "Server closed connection.";
		break;
	case QAbstractSocket::HostNotFoundError:
		err = "Host not found.";
		break;
	case QAbstractSocket::ConnectionRefusedError:
		err = "Connection refused.";
		break;
	default:
		err = "Unknown error.";
	}

	errorOccured(err);
}

void IrcChat::onSockStateChanged() {
	qDebug() << this->connected() << sock->state();
	// We don't check if connected property actually changed because this slot should only be awaken when it did
	emit connectedChanged();
}

bool IrcChat::connected() {
	return sock->state() == QTcpSocket::ConnectedState;
}

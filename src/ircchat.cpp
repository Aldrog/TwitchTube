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
	chatModel = new MessageListModel(this);
	// Open socket
	sock = new QTcpSocket(this);
	if(sock) {
		emit errorOccured("Error opening socket");
	}
	sock->connectToHost(HOST, PORT);
	connect(sock, SIGNAL(readyRead()), this, SLOT(receive()));
	connect(sock, SIGNAL(error(QAbstractSocket::SocketError)), this, SLOT(processError(QAbstractSocket::SocketError)));
	connect(sock, SIGNAL(connected()), this, SLOT(onSockStateChanged()));
	connect(sock, SIGNAL(disconnected()), this, SLOT(onSockStateChanged()));
}

IrcChat::~IrcChat() { disconnect(); }

void IrcChat::join(const QString channel) {
	// Tell server that we support twitch-specific commands
	sock->write("CAP REQ :twitch.tv/commands\r\n");
	sock->write("CAP REQ :twitch.tv/tags\r\n");
	// Login
	sock->write(("PASS " + userpass + "\r\n").toStdString().c_str());
	sock->write(("NICK " + username + "\r\n").toStdString().c_str());
	// Join channel's chat room
	sock->write(("JOIN #" + channel + "\r\n").toStdString().c_str());

	QNetworkAccessManager *manager = new QNetworkAccessManager(this);
	connect(manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(badgesReceived(QNetworkReply*)));
	connect(manager, SIGNAL(finished(QNetworkReply*)), manager, SLOT(deleteLater()));
	manager->get(QNetworkRequest(QUrl("https://api.twitch.tv/kraken/chat/" + channel + "/badges")));

	// Save channel name for later use
	room = channel;
}

void IrcChat::setAnonymous(bool newAnonymous) {
	if(newAnonymous != anonym) {
		if(newAnonymous) {
			qsrand(QTime::currentTime().msec());
			username = "";
			username.sprintf("justinfan%06d", qrand() % 1000000);
			userpass = "blah";
		}
		anonym = newAnonymous;
		emit anonymousChanged();
	}
}

void IrcChat::setTextSize(int textSize) {
	if(textSize != _textSize) {
		_textSize = textSize;
		m_emoteSize = textSize * 1.2;
		if(m_emoteSize < 45)
			m_emoteSizeCategory = 1;
		else if(m_emoteSize < 75)
			m_emoteSizeCategory = 2;
        else
			m_emoteSizeCategory = 3;
        emit textSizeChanged();
    }
}

void IrcChat::disconnect() {
	sock->write(("PART #" + room + "\r\n").toStdString().c_str());
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
	sock->write(("PRIVMSG #" + room + " :" + msg + "\r\n").toStdString().c_str());
	addMessage(userSpecs, userColor, userDisplayName, username, parseUserEmotes(msg));
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
		sock->write("PONG\r\n");
		return;
	}
	if(cmd.contains("PRIVMSG")) {
		// Structure of message: '@color=#HEX;display-name=NicK;emotes=id:start-end,start-end/id:start-end;subscriber=0or1;turbo=0or1;user-type=type :nick!nick@nick.tmi.twitch.tv PRIVMSG #channel :message'
		QString params = cmd.left(cmd.indexOf("PRIVMSG"));
		QString nickname = params.left(params.lastIndexOf('!')).remove(0, params.lastIndexOf(':') + 1);
		if(params.lastIndexOf(':') > 0)
			params = params.remove(params.lastIndexOf(':') - 1, params.length());
		else
			params = "";
		// Parsing params
		QString colorCode = getParamValue(params, "color");
		QColor nickColor = colorCode == "" ? getDefaultColor(nickname) : QColor(colorCode);
		QString displayName = getParamValue(params, "display-name");
		QStringList specList = QStringList();
		if(nickname == room)
			specList.append("broadcaster");
		QString utype = getParamValue(params, "user-type");
		if(utype != "")
			specList.append(utype);
		if(getParamValue(params, "subscriber") == "1")
			specList.append("subscriber");
		if(getParamValue(params, "turbo") == "1")
			specList.append("turbo");

		QStringList emoteList = getParamValue(params, "emotes").split('/', QString::SkipEmptyParts);
		QString message = cmd.remove(0, cmd.indexOf(':', cmd.indexOf("PRIVMSG")) + 1);
		// Parsing emotes
		QStringList splittedMessage = QStringList(message);
		QVector<int> smLengths = QVector<int>(1, message.length());
		foreach (QString emote, emoteList) {
			int id = emote.left(emote.indexOf(':')).toInt();
			QString richTextEmote = QString("<img height=%1 src=\'http://static-cdn.jtvnw.net/emoticons/v1/%2/%3.0\'/>").arg(m_emoteSize).arg(id).arg(m_emoteSizeCategory);
			QStringList coordList = emote.remove(0, emote.indexOf(':') + 1).split(',', QString::SkipEmptyParts);
			foreach (QString position, coordList) {
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
		addMessage(specList, nickColor, displayName, nickname, message);
		return;
	}
	if(cmd.contains("NOTICE")) {
		QString text = cmd.remove(0, cmd.indexOf(':', cmd.indexOf("NOTICE")) + 1);
		addNotice(text);
	}
	if(cmd.contains("GLOBALUSERSTATE")) {
		// We are not interested in this one, it only exists because otherwise USERSTATE would be trigged instead
		return;
	}
	if(cmd.contains("USERSTATE")) {
		QString params = cmd.left(cmd.lastIndexOf(':') - 1);
		setUserEmotes(getParamValue(params, "emote-sets"));
		QStringList uspecs = QStringList();
		if(username == room)
			uspecs.append("broadcaster");
		QString utype = getParamValue(params, "user-type");
		if(utype != "")
			uspecs.append(utype);
		if(getParamValue(params, "subscriber") == "1")
			uspecs.append("subscriber");
		if(getParamValue(params, "turbo") == "1")
			uspecs.append("turbo");
		if(userSpecs != uspecs)
			userSpecs = uspecs;
		QString colorCode = getParamValue(params, "color");
		userColor = colorCode == "" ? getDefaultColor(username) : QColor(colorCode);
		userDisplayName = getParamValue(params, "display-name");
		return;
	}
}

QString IrcChat::getParamValue(QString params, QString param) {
	QString paramValue = params.remove(0, params.indexOf(param + "="));
	paramValue = paramValue.left(paramValue.indexOf(';')).remove(0, paramValue.indexOf('=') + 1);
	return paramValue;
}

// Looks like Twitch started to give a random color for every user session. There's no way to get this color, so we continue evaluating color from username.
QColor IrcChat::getDefaultColor(QString name) {
	int n = name[0].unicode() + name[name.length() - 1].unicode();
	return DEFAULT_COLORS[n % (sizeof(DEFAULT_COLORS) / sizeof(*DEFAULT_COLORS))];
}

QString IrcChat::parseUserEmotes(QString msg) {
	QString res = msg;
	foreach (int id, userEmotes.keys()) {
		res = msg.replace(userEmotes[id], QString("<img height=%1 src=\'http://static-cdn.jtvnw.net/emoticons/v1/%2/%3.0\'/>").arg(m_emoteSize).arg(id).arg(m_emoteSizeCategory));
	}
	return res;
}

void IrcChat::addMessage(QStringList specs, QColor uColor, QString d_name, QString uname, QString text) {
	Message msg = Message(specs, uColor, d_name, uname, text, RT(specs, uColor, d_name, uname, text));
	chatModel->appendMessage(msg);
	emit messagesChanged();
}

void IrcChat::addNotice(QString text) {
	Message notice = Message(text, text);
	chatModel->appendMessage(notice);
	emit messagesChanged();
}

QString IrcChat::RT(QStringList specs, QColor uColor, QString d_name, QString uname, QString text) {
	QString ubadges = "";
	foreach(QString uspec, specs) {
		ubadges += QString("<img height=%1 src=%2/> ").arg(textSize()).arg(badges[uspec]);
	}

	return ubadges + QString("<font color=%1>%2</font>: %3").arg(uColor.name()).arg(d_name != "" ? d_name : uname).arg(text);
}

void IrcChat::badgesReceived(QNetworkReply *dataSource) {
	QByteArray rawData = dataSource->readAll();
	QJsonDocument doc = QJsonDocument::fromJson(rawData);
	QJsonObject data = doc.object();
	foreach(QString spec, data.keys()) {
		if(!data[spec].toObject()["image"].isNull()) {
			badges.insert(spec, data[spec].toObject()["image"].toString());
		}
	}
	dataSource->deleteLater();
}

void IrcChat::emotesReceived(QNetworkReply *dataSource) {
	QByteArray rawData = dataSource->readAll();
	QJsonDocument doc = QJsonDocument::fromJson(rawData);
	QJsonObject data = doc.object();
	foreach(QJsonValue set, data["emoticon_sets"].toObject()) {
		foreach(QJsonValue emote, set.toArray()) {
			userEmotes.insert(emote.toObject()["id"].toInt(), QRegExp("\\b" + emote.toObject()["code"].toString() + "\\b"));
		}
	}
	qDebug() << "Received" << userEmotes.count() << "user emotes";
	dataSource->deleteLater();
}

void IrcChat::setUserEmotes(QString emoteSets) {
	if(emoteSets != userEmoteSets) {
		QNetworkAccessManager *manager = new QNetworkAccessManager(this);
		connect(manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(emotesReceived(QNetworkReply*)));
		connect(manager, SIGNAL(finished(QNetworkReply*)), manager, SLOT(deleteLater()));
		manager->get(QNetworkRequest(QUrl("https://api.twitch.tv/kraken/chat/emoticon_images?emotesets=" + emoteSets)));
	}
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
	// We don't check if connected property actually changed because this slot should only be awaken when it did
	emit connectedChanged();
}

bool IrcChat::connected() {
	return sock->state() == QTcpSocket::ConnectedState;
}

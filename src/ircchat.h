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

#ifndef IRCCHAT_H
#define IRCCHAT_H

#include <QObject>
#include <QTcpSocket>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QMap>
#include <QRegExp>
#include <QColor>
#include <QQmlListProperty>
#include "messagelistmodel.h"
#include "message.h"

const qint16 PORT = 6667;
const QString HOST = "irc.twitch.tv";
const QColor DEFAULT_COLORS[15] = {	QColor("#FF0000"),	// Red
									QColor("#0000FF"),	// Blue
									QColor("#00FF00"),	// Green
									QColor("#B22222"),	// FireBrick
									QColor("#FF7F50"),	// Coral
									QColor("#9ACD32"),	// YellowGreen
									QColor("#FF4500"),	// OrangeRed
									QColor("#2E8B57"),	// SeaGreen
									QColor("#DAA520"),	// GoldenRod
									QColor("#D2691E"),	// Chocolate
									QColor("#5F9EA0"),	// CadetBlue
									QColor("#1E90FF"),	// DodgerBlue
									QColor("#FF69B4"),	// HotPink
									QColor("#8A2BE2"),	// BlueViolet
									QColor("#00FF7F"),	// SpringGreen
								  };

// Backend for chat
class IrcChat : public QObject
{
	Q_OBJECT
public:
	IrcChat(QObject *parent = 0);
	~IrcChat();

	//# User
	Q_PROPERTY(QString name MEMBER username)
	Q_PROPERTY(QString password MEMBER userpass)
	QString username, userpass;
	QMap<int, QRegExp> userEmotes;
	QStringList userSpecs;
	QColor userColor;
	QString userDisplayName;

	//# Network
	Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
	bool connected();

	//# Text and twitch-specific functionality
    Q_PROPERTY(int textSize READ textSize WRITE setTextSize NOTIFY textSizeChanged)
    inline int textSize() { return _textSize; }
	void setTextSize(int textSize);
	Q_PROPERTY(MessageListModel* messages READ messages NOTIFY messagesChanged)
	inline MessageListModel *messages() { return chatModel; }
	Q_INVOKABLE void join(const QString channel);
	Q_INVOKABLE void disconnect();
	Q_INVOKABLE void reopenSocket();
	void addMessage(QStringList specs, QColor uColor, QString d_name, QString uname, QString text);
	void addNotice(QString text);
signals:
	void textSizeChanged();
	void messagesChanged();
	void errorOccured(QString errorDescription);
	void connectedChanged();
public slots:
	void sendMessage(const QString &msg);
	void onSockStateChanged();
private slots:
	void receive();
	void processError(QAbstractSocket::SocketError socketError);
	void badgesReceived(QNetworkReply *dataSource);
	void emotesReceived(QNetworkReply *dataSource);
private:
	void parseCommand(QString cmd);
	QString getParamValue(QString params, QString param);
	QColor getDefaultColor(QString name);
	QString parseUserEmotes(QString msg);
	QString RT(QStringList specs, QColor uColor, QString d_name, QString uname, QString text);
	//Message *formRTMessage(QStringList specs, QColor uColor, QString d_name, QString uname, QString text);
	//void formRTMessage(Message *incompleteMsg);
	QTcpSocket *sock;
	QString room;
	int _emoteSize;
	int _textSize;
	QMap<QString, QString> badges;
	MessageListModel *chatModel;
	// Comma-separated list of set numbers
	QString userEmoteSets;
	void setUserEmotes(QString emoteSets);
};

#endif // IRCCHAT_H

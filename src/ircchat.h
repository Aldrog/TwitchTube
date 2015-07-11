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
#include <QColor>
#include <QMap>
#include <QRegExp>

const qint16 PORT = 6667;
const QString HOST = "irc.twitch.tv";
const QColor DEFAULTCOLORS[15] = {	QColor("#FF0000"),	// Red
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
	Q_PROPERTY(QString name MEMBER nick)
	Q_PROPERTY(QString password MEMBER ircpass)
	Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
	// emoteSize should always be 1, 2 or 3
	Q_PROPERTY(int emoteSize MEMBER _emoteSize)
	Q_PROPERTY(QStringList chatList READ chatList WRITE setChatList NOTIFY chatListChanged)

	explicit IrcChat(QObject *parent = 0);
	~IrcChat();

	bool connected();
	inline QStringList chatList() { return chat; }
	void setChatList(QStringList newChatList);
	void addMessage(QString badges, QColor nickColor, QString sender, QString displayName, QString message);
	void addNotice(QString text);
	Q_INVOKABLE void setBadge(QString name, QString imageURL);
	Q_INVOKABLE void setUserEmote(int id, QString pattern);
	Q_INVOKABLE void join(const QString channel);
	Q_INVOKABLE void disconnect();
	Q_INVOKABLE void reopenSocket();
signals:
	void chatListChanged();
	void errorOccured(QString errorDescription);
	void connectedChanged();
public slots:
	void sendMessage(const QString &msg);
	void onSockStateChanged();
private slots:
	void receive();
	void processError(QAbstractSocket::SocketError socketError);
private:
	void parseCommand(QString cmd);
	QString getParamValue(QString params, QString param);
	QColor getDefaultColor(QString name);
	QString parseUserEmotes(QString msg);
	QString nick, ircpass;
	QTcpSocket *sock;
	QString room;
	int _emoteSize;
	QMap<QString, QString> badges;
	QMap<int, QRegExp> userEmotes;

	QStringList chatMessages, chatNicknames, chatBadges, chat;
	QList<bool> highlighted;
};

#endif // IRCCHAT_H

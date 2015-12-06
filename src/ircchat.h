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
#include <QNetworkReply>
#include <QMap>
#include <QRegExp>
#include <QColor>
#include <QQmlListProperty>
#include "messagelistmodel.h"
#include "message.h"

const qint16 PORT = 6667;
const QString HOST = "irc.twitch.tv";
const QColor DEFAULT_COLORS[15] = { QColor("#FF0000"),  // Red
                                    QColor("#0000FF"),  // Blue
                                    QColor("#00FF00"),  // Green
                                    QColor("#B22222"),  // FireBrick
                                    QColor("#FF7F50"),  // Coral
                                    QColor("#9ACD32"),  // YellowGreen
                                    QColor("#FF4500"),  // OrangeRed
                                    QColor("#2E8B57"),  // SeaGreen
                                    QColor("#DAA520"),  // GoldenRod
                                    QColor("#D2691E"),  // Chocolate
                                    QColor("#5F9EA0"),  // CadetBlue
                                    QColor("#1E90FF"),  // DodgerBlue
                                    QColor("#FF69B4"),  // HotPink
                                    QColor("#8A2BE2"),  // BlueViolet
                                    QColor("#00FF7F"),  // SpringGreen
                                  };

// Backend for chat
class IrcChat : public QObject
{
    Q_OBJECT
public:
    IrcChat(QObject *parent = 0);
    ~IrcChat();

    Q_PROPERTY(QString name MEMBER username)
    Q_PROPERTY(QString password MEMBER userpass)
    Q_PROPERTY(bool anonymous READ anonymous WRITE setAnonymous NOTIFY anonymousChanged)
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
    Q_PROPERTY(int textSize READ textSize WRITE setTextSize NOTIFY textSizeChanged)
    Q_PROPERTY(MessageListModel* messages READ messages NOTIFY messagesChanged)

    Q_INVOKABLE void join(const QString channel);
    Q_INVOKABLE void disconnect();
    Q_INVOKABLE void reopenSocket();

    //# User
    QString username, userpass;
    inline bool anonymous() { return anonym; }
    void setAnonymous(bool newAnonymous);
    bool anonym;
    QMap<int, QRegExp> userEmotes;
    QStringList userSpecs;
    QColor userColor;
    QString userDisplayName;

    //# Network
    bool connected();

    //# Text
    inline int textSize() { return textSize_p; }
    void setTextSize(int textSize);
    inline MessageListModel *messages() { return chatModel; }
    void addMessage(QStringList specs, QColor uColor, QString d_name, QString uname, QString text);
    void addNotice(QString text);
signals:
    void textSizeChanged();
    void messagesChanged();
    void errorOccured(QString errorDescription);
    void connectedChanged();
    void anonymousChanged();
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
    void setUserEmotes(QString emoteSets);
    QTcpSocket *sock;
    QString room;
    QMap<QString, QString> badges;
    MessageListModel *chatModel;
    QString userEmoteSets; // Comma-separated list of set ids
    int emoteSize_p;
    int emoteSizeCategory_p;
    int textSize_p;
};

#endif // IRCCHAT_H

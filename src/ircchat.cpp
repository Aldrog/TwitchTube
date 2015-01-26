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

IrcChat::IrcChat() {
	sock = new QTcpSocket(this);
	connect(sock, SIGNAL(readyRead()), this, SLOT(receive()));
	connect(sock, SIGNAL(error(QAbstractSocket::SocketError)), this, SLOT(processError(QAbstractSocket::SocketError)));
	room = "";
}

IrcChat::~IrcChat() { sock->close(); }

void IrcChat::join(const QString channel) {
	sock->connectToHost(HOST, PORT);
	// Tell server that we support twitch-specific commands
	sock->write("TWITCHCLIENT 2\n");
	// Login
	sock->write(("PASS " + ircpass + "\n").toStdString().c_str());
	sock->write(("NICK " + nick + "\n").toStdString().c_str());
	// Join channel's chat room
	sock->write(("JOIN #" + channel + "\n").toStdString().c_str());
	// Save channel name for later use
	room = channel;
}

void IrcChat::sendMessage(const QString &msg) {
	sock->write(("PRIVMSG #" + room + " :" + msg + '\n').toStdString().c_str());
}

void IrcChat::receive() {
	//errorOccured("Connection from server, not error.");
	QString msg;
	while (sock->canReadLine()) {
		msg = sock->readLine();
		// I'm not shure if \n and \r may be in another order, so removing one by one
		msg = msg.remove('\n').remove('\r');
		parseCommand(msg);
	}
}

void IrcChat::parseCommand(QString cmd) {
	if(cmd.startsWith("PING ")) {
		sock->write(("PONG " + cmd.remove("PING ")).toStdString().c_str());
		return;
	}
	if(cmd.contains("PRIVMSG")) {
		if(cmd.startsWith(":jtv")) {
			// Maintenence message
			QString message = cmd.remove(0, cmd.indexOf(':', 1) + 1);
			if(message.startsWith("USERCOLOR")) {
				// Structure: USERCOLOR nick #C0DE
				colorReceived(message.section(' ', 1, 1), message.section(' ', 2, 2));
				return;
			}
			if(message.startsWith("SPECIALUSER")) {
				// Structure: SPECIALUSER nick type
				// types: subscriber, staff, admin, turbo
				specReceived(message.section(' ', 1, 1), message.section(' ', 2, 2));
				return;
			}
			if(message.startsWith("CLEARCHAT")) {
				// Structure: CLEARCHAT nick
				// Someone is banned... But we don't speak about sad
				return;
			}
			if(message.startsWith("EMOTESET")) {
				// Structure: EMOTESET nick [some digits]
				// Don't know what to do here.
				return;
			}
		}
		else {
			// Structure of message: ' :nick!nick@nick.tmi.twitch.tv PRIVMSG #channel :message'
			// nick - from ':' to '!', message - from second ':'
			QString nickname = cmd.left(cmd.indexOf('!')).remove(0,1);
			QString message = cmd.remove(0, cmd.indexOf(':', 2) + 1);
			messageReceived(nickname, message);
			return;
		}
	}
	if(cmd.startsWith(":jtv MODE")){
		if(cmd.contains("+o")) {
			specReceived(cmd.remove(":jtv MODE #" + room + " +o "), "mod");
			return;
		}
		if(cmd.contains("-o")) {
			specRemoved(cmd.remove(":jtv MODE #" + room + " -o "), "mod");
			return;
		}
	}
	if(cmd.startsWith(":" + nick + "!" + nick + "@" + nick + ".tmi.twitch.tv")) {
		// It's our own action
		return;
	}
	if(cmd.startsWith(":" + nick + ".tmi.twitch.tv")) {
		// Here might be error messages, but I've only seen
		// nick = #channel :nick
		// and 'End of /NAMES list'
		return;
	}
	if(cmd.startsWith("HISTORYEND")) {
		return;
	}
	if(cmd.startsWith(":tmi.twitch.tv")) {
		cmd = cmd.remove(0, cmd.indexOf(':', 2) + 1);
	}
	// If we don't know how to parse command
	messageReceived(NULL, cmd);
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

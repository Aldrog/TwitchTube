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
	sock->write(("PASS " + ircpass + "\n").toStdString().c_str());
	sock->write(("NICK " + nick + "\n").toStdString().c_str());
	sock->write(("JOIN #" + channel + "\n").toStdString().c_str());
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
		msg = msg.remove('\n');
		if(msg.startsWith("PING "))
			sock->write(("PONG " + msg.remove("PING ")).toStdString().c_str());
		else if(msg.contains("PRIVMSG")) {
			// Structure of message: ' :nick!nick@nick.tmi.twitch.tv PRIVMSG #channel :message'
			// nick - from ':' to '!', message - from second ':'
			QString nick = msg.left(msg.indexOf('!')).remove(0,1);
			QString message = msg.remove(0, msg.indexOf(':', 2) + 1);
			messageReceived(nick, message);
		}
		else {
			messageReceived("twitch", msg);
		}
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

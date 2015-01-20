#ifndef IRCCHAT_H
#define IRCCHAT_H

#include <QObject>
#include <QTcpSocket>

const qint16 PORT = 6667;
const QString HOST = "irc.twitch.tv";

// Backend for chat
class IrcChat : public QObject
{
	Q_OBJECT
public:
	QString nick, ircpass;
	Q_PROPERTY(QString name MEMBER nick)
	Q_PROPERTY(QString pass MEMBER ircpass)

	IrcChat();
	~IrcChat();

	Q_INVOKABLE void join(const QString channel);
signals:
	void messageReceived(QString sndnick, QString msg);
	void errorOccured(QString errorDescription);
public slots:
	void sendMessage(const QString &msg);
private slots:
	void receive();
	void processError(QAbstractSocket::SocketError socketError);
private:
	QTcpSocket *sock;
	QString room;
};

#endif // IRCCHAT_H

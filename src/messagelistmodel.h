#ifndef MESSAGELISTMODEL_H
#define MESSAGELISTMODEL_H

#include <QAbstractListModel>
#include <QList>
#include <QHash>
#include <QVariant>
#include "message.h"

class MessageListModel : public QAbstractListModel
{
	Q_OBJECT
public:
	enum MessageRoles {
		RichTextMessageRole = Qt::UserRole + 1,
		IsNoticeRole
	};

	MessageListModel(QObject *parent = 0);

	int rowCount(const QModelIndex &parent = QModelIndex()) const;
	QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
	void appendMessage(Message &message);
signals:

public slots:

protected:
	QHash<int, QByteArray> roleNames() const;
private:
	QList<Message> messageList;
};

#endif // MESSAGELISTMODEL_H

#include "messagelistmodel.h"
#include <QDebug>

MessageListModel::MessageListModel(QObject *parent) :
	QAbstractListModel(parent) {
	messageList = QList<Message>();
}

int MessageListModel::rowCount(const QModelIndex &parent) const {
	Q_UNUSED(parent)
	return messageList.count();
}

QVariant MessageListModel::data(const QModelIndex &index, int role) const {
	if (index.row() < 0 || index.row() >= rowCount())
		return QVariant();

	Message msg = messageList[index.row()];
	if (role == RichTextMessageRole)
		return msg.richTextMessage;
	else if (role == IsNoticeRole)
		return msg.notice;
	return QVariant();
}

void MessageListModel::appendMessage(Message &message) {
	beginInsertRows(QModelIndex(), rowCount(), rowCount());
	messageList.append(message);
	endInsertRows();
}

QHash<int, QByteArray> MessageListModel::roleNames() const {
	return QHash<int, QByteArray>({{RichTextMessageRole, "richTextMessage"}, {IsNoticeRole, "isNotice"}});
}

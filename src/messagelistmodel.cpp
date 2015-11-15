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
	if(rowCount() > MAX_MESSAGE_POOL) {
		beginRemoveRows(QModelIndex(), 0, 0);
		messageList.removeFirst();
		endRemoveRows();
	}
	beginInsertRows(QModelIndex(), rowCount(), rowCount());
	messageList.append(message);
	endInsertRows();
}

QHash<int, QByteArray> MessageListModel::roleNames() const {
	return QHash<int, QByteArray>({{RichTextMessageRole, "richTextMessage"}, {IsNoticeRole, "isNotice"}});
}

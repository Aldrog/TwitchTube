/*
 * Copyright © 2015-2017 Andrew Penkrat
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

#ifndef MESSAGELISTMODEL_H
#define MESSAGELISTMODEL_H

#include <QAbstractListModel>
#include <QList>
#include <QHash>
#include <QVariant>
#include "message.h"

const int MAX_MESSAGE_POOL = 1000;

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

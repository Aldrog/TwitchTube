#ifndef QMLSETTINGS_H
#define QMLSETTINGS_H

#include <QSettings>

class QMLSettings : public QSettings
{
	Q_OBJECT
public:
	explicit QMLSettings(QObject *parent = 0);

signals:

public slots:

};

#endif // QMLSETTINGS_H

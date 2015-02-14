#ifndef TOOLS_H
#define TOOLS_H

#include <QObject>
#include <QStringList>
#include <QDir>
#include <QStandardPaths>

class Tools : public QObject
{
	Q_OBJECT
public:
	Tools();
	~Tools();

	Q_INVOKABLE int clearCookies();
};

#endif // TOOLS_H

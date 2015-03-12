#include "tools.h"

/* Return codes:
 * 0 - success
 * 1 - cache doesn't exist
 * -1 - cannot delete cache
 * -2 - failed to find cache directory
 */
int Tools::clearCookies() {
	QStringList dataPaths = QStandardPaths::standardLocations(QStandardPaths::DataLocation);
	if(dataPaths.size()) {
		QDir webData(QDir(dataPaths.at(0)).filePath(".QtWebKit"));
		if(webData.exists()) {
			if(webData.removeRecursively())
				return 0;
			else
				return -1;
		}
		else
			return 1;
	}
	return -2;
}

Tools::Tools(QObject *parent) :	QObject(parent) { }
Tools::~Tools() { }

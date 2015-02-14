# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-twitchtube

CONFIG += sailfishapp

SOURCES += \
    src/harbour-twitchtube.cpp \
    src/ircchat.cpp \
    src/tools.cpp

OTHER_FILES += \
    qml/cover/CoverPage.qml \
    translations/*.ts \
    qml/pages/GamesPage.qml \
    qml/pages/ChannelsPage.qml \
    qml/pages/StreamPage.qml \
    qml/pages/scripts/httphelper.js \
    qml/pages/SettingsPage.qml \
    qml/pages/SearchPage.qml \
    qml/pages/LoginPage.qml \
    qml/pages/FollowedPage.qml \
    qml/harbour-twitchtube.qml \
    harbour-twitchtube.desktop \
    harbour-twitchtube.png \
    rpm/harbour-twitchtube.changes.in \
    rpm/harbour-twitchtube.spec \
    rpm/harbour-twitchtube.yaml \
    qml/pages/scripts/chathelper.js \
    qml/pages/elements/Categories.qml \
    qml/pages/QualityChooserPage.qml

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
#TRANSLATIONS += translations/harbour-twitchtube-ru.ts

HEADERS += \
    src/ircchat.h \
    src/tools.h


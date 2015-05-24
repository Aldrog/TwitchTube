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

QT += dbus

SOURCES += \
    src/harbour-twitchtube.cpp \
    src/ircchat.cpp \
    src/tools.cpp \
    src/qmlsettings.cpp

OTHER_FILES += \
    translations/*.ts \
    qml/pages/GamesPage.qml \
    qml/pages/ChannelsPage.qml \
    qml/pages/StreamPage.qml \
    qml/js/httphelper.js \
    qml/pages/SettingsPage.qml \
    qml/pages/SearchPage.qml \
    qml/pages/LoginPage.qml \
    qml/pages/FollowedPage.qml \
    qml/harbour-twitchtube.qml \
    harbour-twitchtube.desktop \
    harbour-twitchtube.png \
    rpm/harbour-twitchtube.spec \
    rpm/harbour-twitchtube.yaml \
    qml/js/chathelper.js \
    qml/pages/elements/Categories.qml \
    qml/pages/QualityChooserPage.qml \
    rpm/harbour-twitchtube.changes \
    qml/images/cross.png \
    qml/images/heart.png \
    qml/images/icon.png \
    qml/pages/elements/GamesGrid.qml \
    qml/pages/elements/ChannelsGrid.qml \
    qml/pages/GameChannelsPage.qml \
    qml/pages/FollowedGamesPage.qml \
    qml/cover/NavigationCover.qml \
    qml/cover/StreamCover.qml

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
#TRANSLATIONS += translations/harbour-twitchtube-ru.ts

HEADERS += \
    src/ircchat.h \
    src/tools.h \
    src/qmlsettings.h


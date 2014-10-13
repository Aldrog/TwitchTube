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
TARGET = Twitch

CONFIG += sailfishapp

SOURCES += src/Twitch.cpp

OTHER_FILES += qml/Twitch.qml \
    qml/cover/CoverPage.qml \
    rpm/Twitch.changes.in \
    rpm/Twitch.spec \
    rpm/Twitch.yaml \
    translations/*.ts \
    Twitch.desktop \
    qml/pages/GamesPage.qml \
    qml/pages/ChannelsPage.qml \
    qml/pages/StreamPage.qml

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/Twitch-de.ts


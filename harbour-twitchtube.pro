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

DEFINES += OS_SAILFISH

include(common.pri)

RESOURCES += sailfish-ui/TwitchTube.qrc

QML_FILES += $$files(sailfish-ui/*.qml,true) \
             $$files(sailfish-ui/*.js,true) \
             $$files(sailfish-ui/*.png,true)

CONF_FILES += rpm/harbour-twitchtube.spec \
              rpm/harbour-twitchtube.yaml \
              rpm/harbour-twitchtube.changes

TRANSLATIONS += $$files(translations/*.ts)

OTHER_FILES += $${CONF_FILES} \
               $${QML_FILES} \
               harbour-twitchtube.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

DISTFILES += \
    sailfish-ui/Main.qml

